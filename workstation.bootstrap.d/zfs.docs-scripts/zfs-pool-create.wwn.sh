#!/bin/bash
zpool create sechszehn mirror wwn-0x55cd2e404c6d54ba wwn-0x55cd2e404c6d54e8 \
mirror wwn-0x55cd2e414d429f18 wwn-0x55cd2e414d85ca38 \
mirror wwn-0x55cd2e404c6d54b9 wwn-0x55cd2e404c6d5557 \
mirror wwn-0x55cd2e414d8870fc wwn-0x55cd2e414d8871a7 \
mirror wwn-0x55cd2e414d887289 wwn-0x55cd2e414d886f4a \
mirror wwn-0x55cd2e414d85c182 wwn-0x55cd2e414d88728d \
mirror wwn-0x55cd2e414d886f80 wwn-0x55cd2e414d887294 \
mirror wwn-0x55cd2e414d886fca wwn-0x55cd2e414d887303

zpool add sechszehn cache nvme-eui.002538c27100a8ef
zpool add sechszehn log nvme-eui.002538c27100a8b7
