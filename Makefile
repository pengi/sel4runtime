OUT?=out
BUILD?=build

CC=$(TARGET_PREFIX)gcc
LD=$(TARGET_PREFIX)ld

include $(SEL4)/support/sel4_config.mk

SEL4_ARCH=$(SEL4_KernelSel4Arch)
SEL4_MODE=$(SEL4_KernelWordSize)

SRCS=\
	crt/sel4_arch/$(SEL4_ARCH)/crt0.S \
	crt/sel4_arch/$(SEL4_ARCH)/crti.S \
	crt/sel4_arch/$(SEL4_ARCH)/crtn.S \
	crt/sel4_arch/$(SEL4_ARCH)/sel4_crt0.S \
	src/crt1.c \
	src/env.c \
	src/init.c \
	src/memcpy.c \
	src/memset.c \
	src/start.c \
	src/start_root.c \
	src/vsyscall.c

ifneq (,$(filter $(SEL4_ARCH),aarch32 arm_hyp))
SRCS+=\
	src/sel4_arch/$(SEL4_ARCH)/__aeabi_read_tp_c.c \
	src/sel4_arch/$(SEL4_ARCH)/__aeabi_read_tp.S
endif

OBJS=\
	$(patsubst %.S, $(BUILD)/%.o, $(filter %.S, $(SRCS))) \
	$(patsubst %.c, $(BUILD)/%.o, $(filter %.c, $(SRCS))) \
	$(BUILD)/sel4_bootinfo.o

$(info objs $(OBJS))

CFLAGS=\
	$(BASE_CFLAGS) \
	-Wall \
	-Werror \
	-Wextra \
	-Iinclude \
	-Iinclude/sel4_arch/$(SEL4_ARCH) \
	-Iinclude/mode/$(SEL4_MODE) \
	-I$(SEL4)/libsel4/include \
	-fno-common \
	-fno-pie

LDFLAGS=\
	$(BASE_LDFLAGS) \
	--relocatable

all: $(OUT)/lib/sel4runtime.o
.PHONY: all

$(OUT)/lib/sel4runtime.o: $(OBJS)
	@mkdir -p $(@D)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD)/sel4_bootinfo.o: $(SEL4)/libsel4/src/sel4_bootinfo.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD)/%.o: %.S
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $^