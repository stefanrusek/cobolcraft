#### Phase 14: US13-proto — command nodes and suggestions

- [x] T0161 [US13-proto] Extend `proto/tests/contract_wire_provider.cob` with the Commands, Command Suggestions, Chat Command, Player Chat and Disguised Chat fixtures
- [x] T0162 [US13-proto] Write tests in `proto/tests/test_command_nodes.cob` for every parser kind with its properties and the redirect and suggestion-type fields (15, 15a)
- [x] T0163 [US13-proto] Implement the full command node tree encoder and decoder in `proto/src/command-nodes.cob`
- [x] T0164 [US13-proto] Write tests in `proto/tests/test_chat_commands.cob` for Command Suggestions request and response, Chat Command, Player Chat and Disguised Chat with the standard chat types
- [x] T0165 [US13-proto] Implement those packets in `proto/src/chat-commands.cob`
- [x] T0166 [US13-proto] Gate: run `make gate-proto` and record the command and real output
