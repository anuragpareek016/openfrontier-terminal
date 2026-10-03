#include <errno.h>
#include <libgen.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int is_arg(const char *value, const char *expected) {
    return value != NULL && strcmp(value, expected) == 0;
}

static void print_version(void) {
    puts("OpenFrontier 1.3.1\n");
    puts("Personal terminal build for OpenFrontier Labs");
    puts("Engine compatibility: 1.3.1");
}

static void print_help(void) {
    puts("Usage: OpenFrontier [+action] [options]\n");
    puts("Run OpenFrontier or one of its terminal helper actions.");
    puts("Configuration: ~/.config/openfrontier/config\n");
    puts("Common actions:");
    puts("  +version          Show build information");
    puts("  +show-config      Show the active configuration");
    puts("  +validate-config  Validate configuration files");
    puts("  +edit-config      Open the configuration file");
    puts("  +list-themes      Browse bundled themes");
    puts("  +list-fonts       List available fonts");
    puts("  +list-keybinds    List active key bindings");
}

int main(int argc, char **argv) {
    if (argc == 2 && (is_arg(argv[1], "+version") || is_arg(argv[1], "--version"))) {
        print_version();
        return 0;
    }

    if (argc == 2 && (is_arg(argv[1], "+help") || is_arg(argv[1], "--help") || is_arg(argv[1], "-h"))) {
        print_help();
        return 0;
    }

    char executable[PATH_MAX];
    uint32_t size = sizeof(executable);
    if (_NSGetExecutablePath(executable, &size) != 0) {
        fputs("OpenFrontier: executable path is too long\n", stderr);
        return 126;
    }

    char resolved[PATH_MAX];
    if (realpath(executable, resolved) == NULL) {
        fprintf(stderr, "OpenFrontier: cannot resolve executable path: %s\n", strerror(errno));
        return 126;
    }

    char *directory = dirname(resolved);
    char core[PATH_MAX];
    if (snprintf(core, sizeof(core), "%s/OpenFrontierCore", directory) >= (int)sizeof(core)) {
        fputs("OpenFrontier: core path is too long\n", stderr);
        return 126;
    }

    execv(core, argv);
    fprintf(stderr, "OpenFrontier: cannot launch core: %s\n", strerror(errno));
    return 126;
}
