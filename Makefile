RELEASE_DIR=${TMP_DIR}/harmonia

.PHONY : luacheck
luacheck:
	luacheck .

# Release step specifically when the modpack is under a game, this will copy
# the modpack to the TMP_DIR
.PHONY: prepare.release
prepare.release:
	mkdir -p "${RELEASE_DIR}"

	cp -r --parents harmonia_crystals "${RELEASE_DIR}"
	cp -r --parents harmonia_element "${RELEASE_DIR}"
	cp -r --parents harmonia_exp "${RELEASE_DIR}"
	cp -r --parents harmonia_mana "${RELEASE_DIR}"
	cp -r --parents harmonia_materials "${RELEASE_DIR}"
	cp -r --parents harmonia_nyctophobia "${RELEASE_DIR}"
	cp -r --parents harmonia_passive "${RELEASE_DIR}"
	cp -r --parents harmonia_pottery "${RELEASE_DIR}"
	cp -r --parents harmonia_totems "${RELEASE_DIR}"
	cp -r --parents harmonia_treasure "${RELEASE_DIR}"
	cp -r --parents harmonia_world_mana "${RELEASE_DIR}"

	cp LICENSE "${RELEASE_DIR}"
	cp modpack.conf "${RELEASE_DIR}"
	cp README.md "${RELEASE_DIR}"
