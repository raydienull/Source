# SphereServer makefile (Linux)
#
# Usage:
#   make [ARCH=32|64] [NIGHTLY=1] [DEBUG=1]
#
# ARCH=32 is the reference build. ARCH=64 is experimental until the codebase is fully 64-bit safe.

ARCH		?= 32
TARGET_NAME	:= spheresvr

ifdef DEBUG
	CONFIG	:= debug
else ifdef NIGHTLY
	CONFIG	:= nightly
else
	CONFIG	:= release
endif

BUILD_DIR	:= build/linux$(ARCH)-$(CONFIG)
TARGET		:= $(BUILD_DIR)/$(TARGET_NAME)
VERSION_FILE	:= src/common/version.h

MAKEFLAGS	+= -j$(shell nproc)

CXX		?= g++
CC		?= gcc

# MySQL client library (MariaDB Connector/C or MySQL client)
DB_CONFIG	:= $(shell command -v mariadb_config 2>/dev/null || command -v mysql_config 2>/dev/null)
DB_CFLAGS	:= $(shell $(DB_CONFIG) --include 2>/dev/null)
DB_LIBS		:= $(shell $(DB_CONFIG) --libs 2>/dev/null)


# COMPILER FLAGS

ARCH_FLAGS	:= -m$(ARCH)
DEFINES		:= -DGRAY_SVR -D_CONSOLE -D_REENTRANT -D_LINUX -D_MTNETWORK -D_NEWGUILDSYSTEM -DTHREAD_TRACK_CALLSTACK
COMMON_FLAGS	:= $(ARCH_FLAGS) -pipe -fexceptions -fnon-call-exceptions -fno-omit-frame-pointer -fno-strict-aliasing -ffast-math

ifdef DEBUG
	DEFINES		+= -D_DEBUG
	COMMON_FLAGS	+= -O0 -ggdb3
else
	COMMON_FLAGS	+= -O2
endif

ifdef NIGHTLY
	DEFINES		+= -D_NIGHTLYBUILD
endif

# Warnings are enabled. The categories still outstanding are silenced one by one
# instead of hiding everything behind -w, so that the count can only go down:
#   overloaded-virtual - the CScriptObj / CGObArray hierarchies hide base overloads
#   class-memaccess    - CGTypedArray moves its elements with memmove/memcpy
WARN_FLAGS	:= -Wall -Wextra -Wno-overloaded-virtual -Wno-class-memaccess \
		   -Wno-unused-but-set-variable -Wno-unknown-pragmas

CXXFLAGS	= $(COMMON_FLAGS) -std=gnu++14 $(WARN_FLAGS) $(DEFINES) $(DB_CFLAGS)
# C sources are all vendored (zlib, libev)
CFLAGS		= $(COMMON_FLAGS) -w $(DEFINES) -DZ_HAVE_UNISTD_H

LDFLAGS		:= $(ARCH_FLAGS) -pthread
ifndef DEBUG
	LDFLAGS	+= -s
endif
LDLIBS		:= $(DB_LIBS) -lpthread -lrt -ldl


# SOURCE FILES

SRC := \
	src/common/CacheableScriptFile.cpp \
	src/common/CArray.cpp \
	src/common/CAssoc.cpp \
	src/common/CAtom.cpp \
	src/common/CDataBase.cpp \
	src/common/CEncrypt.cpp \
	src/common/CException.cpp \
	src/common/CExpression.cpp \
	src/common/CFile.cpp \
	src/common/CFileList.cpp \
	src/common/CGrayData.cpp \
	src/common/CGrayInst.cpp \
	src/common/CGrayMap.cpp \
	src/common/CMD5.cpp \
	src/common/CQueue.cpp \
	src/common/CRect.cpp \
	src/common/CRegion.cpp \
	src/common/CResourceBase.cpp \
	src/common/CScript.cpp \
	src/common/CScriptObj.cpp \
	src/common/CSectorTemplate.cpp \
	src/common/CSocket.cpp \
	src/common/CsvFile.cpp \
	src/common/CString.cpp \
	src/common/CTime.cpp \
	src/common/CVarDefMap.cpp \
	src/common/CVarFloat.cpp \
	src/common/graycom.cpp \
	src/common/ListDefContMap.cpp \
	src/common/libev/wrapper_ev.c \
	src/common/twofish/twofish2.cpp \
	src/common/zlib/adler32.c \
	src/common/zlib/compress.c \
	src/common/zlib/crc32.c \
	src/common/zlib/deflate.c \
	src/common/zlib/gzclose.c \
	src/common/zlib/gzlib.c \
	src/common/zlib/gzread.c \
	src/common/zlib/gzwrite.c \
	src/common/zlib/infback.c \
	src/common/zlib/inffast.c \
	src/common/zlib/inflate.c \
	src/common/zlib/inftrees.c \
	src/common/zlib/trees.c \
	src/common/zlib/uncompr.c \
	src/common/zlib/zutil.c \
	src/graysvr/CAccount.cpp \
	src/graysvr/CBase.cpp \
	src/graysvr/CChar.cpp \
	src/graysvr/CCharact.cpp \
	src/graysvr/CCharBase.cpp \
	src/graysvr/CCharFight.cpp \
	src/graysvr/CCharNPC.cpp \
	src/graysvr/CCharNPCAct.cpp \
	src/graysvr/CCharNPCPet.cpp \
	src/graysvr/CCharNPCStatus.cpp \
	src/graysvr/CCharSkill.cpp \
	src/graysvr/CCharSpell.cpp \
	src/graysvr/CCharStatus.cpp \
	src/graysvr/CCharUse.cpp \
	src/graysvr/CChat.cpp \
	src/graysvr/CClient.cpp \
	src/graysvr/CClientDialog.cpp \
	src/graysvr/CClientEvent.cpp \
	src/graysvr/CClientGMPage.cpp \
	src/graysvr/CClientLog.cpp \
	src/graysvr/CClientMsg.cpp \
	src/graysvr/CClientTarg.cpp \
	src/graysvr/CClientUse.cpp \
	src/graysvr/CContain.cpp \
	src/graysvr/CGMPage.cpp \
	src/graysvr/CItem.cpp \
	src/graysvr/CItemBase.cpp \
	src/graysvr/CItemMulti.cpp \
	src/graysvr/CItemMultiCustom.cpp \
	src/graysvr/CItemShip.cpp \
	src/graysvr/CItemSp.cpp \
	src/graysvr/CItemStone.cpp \
	src/graysvr/CItemVend.cpp \
	src/graysvr/CLog.cpp \
	src/graysvr/CObjBase.cpp \
	src/graysvr/CPathFinder.cpp \
	src/graysvr/CQuest.cpp \
	src/graysvr/CResource.cpp \
	src/graysvr/CResourceCalc.cpp \
	src/graysvr/CResourceDef.cpp \
	src/graysvr/CSector.cpp \
	src/graysvr/CServer.cpp \
	src/graysvr/CServRef.cpp \
	src/graysvr/CWebPage.cpp \
	src/graysvr/CWorld.cpp \
	src/graysvr/CWorldImport.cpp \
	src/graysvr/CWorldMap.cpp \
	src/graysvr/graysvr.cpp \
	src/graysvr/PingServer.cpp \
	src/graysvr/UnixTerminal.cpp \
	src/network/network.cpp \
	src/network/packet.cpp \
	src/network/receive.cpp \
	src/network/send.cpp \
	src/sphere/asyncdb.cpp \
	src/sphere/linuxev.cpp \
	src/sphere/mutex.cpp \
	src/sphere/ProfileData.cpp \
	src/sphere/strings.cpp \
	src/sphere/threads.cpp

OBJS := $(patsubst %,$(BUILD_DIR)/%.o,$(SRC))
DEPS := $(OBJS:.o=.d)


# BUILD RULES

.PHONY: all clean flags version

all: $(TARGET)

clean:
	@rm -rf build/

flags:
	@echo 'C++ compiler:	$(CXX) $(CXXFLAGS)'
	@echo 'C compiler:	$(CC) $(CFLAGS)'
	@echo 'Linker:		$(LDFLAGS) $(LDLIBS)'

# Regenerated on every build, but only rewritten when the git revision changes
version:
	@COUNT=$$(git rev-list --count HEAD 2>/dev/null || echo 0); \
	HASH=$$(git rev-parse --short HEAD 2>/dev/null || echo unknown); \
	NEW=$$(printf '// Auto-generated by the build system. Do not edit.\n#define SPHERE_BUILD_NUMBER %s\n#define SPHERE_GIT_HASH "%s"\n' "$$COUNT" "$$HASH"); \
	if [ ! -f $(VERSION_FILE) ] || [ "$$NEW" != "$$(cat $(VERSION_FILE))" ]; then \
		printf '%s\n' "$$NEW" > $(VERSION_FILE); \
		echo "Build number: $$COUNT (git $$HASH)"; \
	fi

$(VERSION_FILE): version

$(TARGET): $(OBJS)
	@echo '  Linking $@'
	@$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

# Vendored C++ is not ours to clean up
$(BUILD_DIR)/src/common/twofish/%.o: WARN_FLAGS := -w

$(BUILD_DIR)/%.cpp.o: %.cpp | $(VERSION_FILE)
	@mkdir -p $(dir $@)
	@echo '  $<'
	@$(CXX) -c $(CXXFLAGS) -MMD -MP $< -o $@

$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo '  $<'
	@$(CC) -c $(CFLAGS) -MMD -MP $< -o $@

-include $(DEPS)
