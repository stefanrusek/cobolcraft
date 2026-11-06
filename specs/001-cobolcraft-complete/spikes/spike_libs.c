/* spike (throwaway): zlib, OpenSSL libcrypto/libssl, BSD sockets on macOS arm64.
   Validates: zlib deflate/inflate (zlib-wrapped, as 01 §3 and 07 §5.2 use) and raw inflate (zip, 08 §1.1);
   gzip (07 §5.1 standalone NBT files); SHA-1 (08 §9.3) and MD5 (02 offline UUID v3) through libcrypto;
   a TLS 1.2+ HTTPS GET through libssl with system trust; non-blocking TCP loopback with poll(). */
#include <zlib.h>
#include <openssl/evp.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <poll.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
static void hex(const unsigned char *b, unsigned n) { for (unsigned i = 0; i < n; i++) printf("%02x", b[i]); printf("\n"); }
static int digest(const char *alg, const void *d, size_t n, unsigned char *out) {
  unsigned len = 0; EVP_MD_CTX *c = EVP_MD_CTX_new(); EVP_DigestInit_ex(c, EVP_get_digestbyname(alg), NULL);
  EVP_DigestUpdate(c, d, n); EVP_DigestFinal_ex(c, out, &len); EVP_MD_CTX_free(c); return (int)len; }
int main(int argc, char **argv) {
  /* zlib */
  const char *msg = "CobolCraft CobolCraft CobolCraft CobolCraft";
  unsigned char z[256], back[256]; uLongf zl = sizeof z, bl = sizeof back;
  int r = compress2(z, &zl, (const Bytef *)msg, strlen(msg), 6);
  r |= uncompress(back, &bl, z, zl);
  printf("zlib %s roundtrip=%d in=%zu deflated=%lu header=%02x%02x\n", zlibVersion(), r == Z_OK && bl == strlen(msg) && !memcmp(back, msg, bl), strlen(msg), zl, z[0], z[1]);
  /* raw inflate: strip 2-byte zlib header and 4-byte adler trailer */
  z_stream s = {0}; inflateInit2(&s, -15); s.next_in = z + 2; s.avail_in = (uInt)(zl - 6); s.next_out = back; s.avail_out = sizeof back;
  r = inflate(&s, Z_FINISH); printf("raw-inflate rc=%d out=%lu\n", r, s.total_out); inflateEnd(&s);
  /* gzip via windowBits 31 */
  z_stream g = {0}; unsigned char gz[256]; deflateInit2(&g, 6, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY);
  g.next_in = (Bytef *)msg; g.avail_in = strlen(msg); g.next_out = gz; g.avail_out = sizeof gz; deflate(&g, Z_FINISH);
  printf("gzip magic=%02x%02x len=%lu\n", gz[0], gz[1], g.total_out); deflateEnd(&g);
  /* crypto */
  unsigned char md[64];
  printf("openssl %s\n", OpenSSL_version(OPENSSL_VERSION));
  printf("sha1(abc)="); hex(md, digest("SHA1", "abc", 3, md));
  const char *off = "OfflinePlayer:Notch"; int n = digest("MD5", off, strlen(off), md);
  md[6] = (md[6] & 0x0f) | 0x30; md[8] = (md[8] & 0x3f) | 0x80;
  printf("offline-uuid(Notch)="); hex(md, n);
  /* sockets: nonblocking loopback */
  int ls = socket(AF_INET, SOCK_STREAM, 0); int one = 1; setsockopt(ls, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
  struct sockaddr_in a = { .sin_family = AF_INET, .sin_port = 0, .sin_addr.s_addr = htonl(INADDR_LOOPBACK) };
  bind(ls, (struct sockaddr *)&a, sizeof a); listen(ls, 8); socklen_t al = sizeof a; getsockname(ls, (struct sockaddr *)&a, &al);
  fcntl(ls, F_SETFL, O_NONBLOCK);
  int cs = socket(AF_INET, SOCK_STREAM, 0); fcntl(cs, F_SETFL, O_NONBLOCK);
  r = connect(cs, (struct sockaddr *)&a, sizeof a); printf("nb-connect rc=%d errno=%s\n", r, r ? strerror(errno) : "-");
  struct pollfd p = { .fd = ls, .events = POLLIN }; poll(&p, 1, 1000);
  int as = accept(ls, NULL, NULL); printf("accepted=%d\n", as >= 0);
  setsockopt(cs, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
  struct pollfd pw = { .fd = cs, .events = POLLOUT }; poll(&pw, 1, 1000);
  ssize_t w = send(cs, "\x10\x00", 2, 0); char rb[8]; struct pollfd pr = { .fd = as, .events = POLLIN }; poll(&pr, 1, 1000);
  ssize_t rd = recv(as, rb, sizeof rb, 0); printf("sent=%zd recv=%zd\n", w, rd);
  ssize_t again = recv(as, rb, sizeof rb, 0); printf("recv-empty rc=%zd errno=%s\n", again, strerror(errno));
  close(cs); poll(&pr, 1, 1000); printf("recv-after-peer-close=%zd\n", recv(as, rb, sizeof rb, 0));
  /* TLS: HTTPS GET (read-only) */
  const char *host = argc > 1 ? argv[1] : "example.com";
  struct addrinfo hints = { .ai_socktype = SOCK_STREAM }, *ai = NULL;
  if (getaddrinfo(host, "443", &hints, &ai) != 0) { printf("tls: dns failed\n"); return 0; }
  int ts = socket(ai->ai_family, SOCK_STREAM, 0);
  if (connect(ts, ai->ai_addr, ai->ai_addrlen) != 0) { printf("tls: connect failed %s\n", strerror(errno)); return 0; }
  SSL_CTX *ctx = SSL_CTX_new(TLS_client_method()); SSL_CTX_set_min_proto_version(ctx, TLS1_2_VERSION);
  SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);
  int dflt = SSL_CTX_set_default_verify_paths(ctx);
  SSL *ssl = SSL_new(ctx); SSL_set_fd(ssl, ts); SSL_set_tlsext_host_name(ssl, host); SSL_set1_host(ssl, host);
  int hc = SSL_connect(ssl);
  printf("tls default_verify_paths=%d handshake=%d verify=%ld (%s) version=%s\n", dflt, hc, SSL_get_verify_result(ssl),
    X509_verify_cert_error_string(SSL_get_verify_result(ssl)), SSL_get_version(ssl));
  if (hc == 1) { char req[256]; snprintf(req, sizeof req, "GET / HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n", host);
    SSL_write(ssl, req, (int)strlen(req)); char resp[64] = {0}; SSL_read(ssl, resp, 40); printf("http-status-line=%.*s\n", (int)strcspn(resp, "\r"), resp); }
  else ERR_print_errors_fp(stdout);
  return 0;
}
