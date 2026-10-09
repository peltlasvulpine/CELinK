# ----------------------------
# Makefile Options
# ----------------------------

NAME = CELINK
ICON = icon.png
DESCRIPTION = "CELinK"
COMPRESSED = YES

CFLAGS = -Wall -Wextra -Oz
CXXFLAGS = -Wall -Wextra -Oz

# ----------------------------

include $(shell cedev-config --makefile)
