#### Phase 16: US15-proto — entity spawn and metadata

- [x] T0171 [US15-proto] Extend `proto/tests/contract_wire_provider.cob` with the Spawn Entity, Set Entity Data and Entity Event fixtures
- [x] T0172 [US15-proto] Write tests in `proto/tests/test_entity_metadata.cob` for every serializer of `docs/protocol/46-registry-ids.md` §12
- [x] T0173 [US15-proto] Implement the entity metadata entry codecs in `proto/src/entity-metadata.cob`
- [x] T0174 [US15-proto] Write tests in `proto/tests/test_entity_packets.cob` for Spawn Entity and Entity Event (18, 21)
- [x] T0175 [US15-proto] Implement the Spawn Entity and Entity Event codecs in `proto/src/entity-packets.cob`
- [x] T0176 [US15-proto] Gate: run `make gate-proto` and record the command and real output
