## Lane 002-lane-p49b group B (T15200+; phase 49e tests over existing code)

- [x] T15200 [US15-core] Write test `core/tests/test_mob_20_20_1.cob` (20 §20.1, validation 1): creeper blast damage at 0 to 6 blocks (power 3), charged at 2 and 6, beyond 2R nothing, Easy and Hard scaling. Red: Easy 24.333 (13.167 expected) and Hard 24.333 (36.5 expected). Closes T2516
- [x] T15201 [US15-core] Implement the difficulty scaling of a mob blast in `EXPLODE-RUN` (core/src/explode.cob: source above 0: Peaceful 0, Easy min(d/2+1, d), Normal d, Hard 3d/2; 20 §3.1). Closes T2517. NOT covered by the test: the half-exposed case of §20.1 (seen 0.5, 10.33): a partly covered box needs a wall layout the document does not give (EXPLODE-SEEN's sample grid is not in 20 §20.1)
