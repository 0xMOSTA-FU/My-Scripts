#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <fcntl.h>

#define MAX_LENGTH 100
#define USER_FILE "users.txt"

void remove_newline(char *str) {
    size_t len = strlen(str);
    if (len > 0 && str[len - 1] == '\n') {
        str[len - 1] = '\0';
    }
}

void register_user() {
    char username[MAX_LENGTH], password[MAX_LENGTH];
    printf("Create a new account\n");
    printf("Enter username: ");
    fgets(username, sizeof(username), stdin);
    remove_newline(username);
    printf("Enter password: ");
    fgets(password, sizeof(password), stdin);
    remove_newline(password);
    FILE *file = fopen(USER_FILE, "a");
    if (file == NULL) {
        perror("Error opening file");
        exit(1);
    }
    fprintf(file, "%s\n%s\n", username, password);
    fclose(file);
    printf("Account created successfully!\n");
}

int verify_login() {
    char input_user[MAX_LENGTH], input_pass[MAX_LENGTH];
    char stored_user[MAX_LENGTH], stored_pass[MAX_LENGTH];
    FILE *file = fopen(USER_FILE, "r");
    if (file == NULL) {
        printf("No account found. Please register first.\n");
        return 0;
    }
    while (1) {
        printf("\nLogin to Mini Linux OS\n");
        printf("Username: ");
        fgets(input_user, sizeof(input_user), stdin);
        remove_newline(input_user);
        printf("Password: ");
        fgets(input_pass, sizeof(input_pass), stdin);
        remove_newline(input_pass);
        rewind(file);
        int valid = 0;
        while (fgets(stored_user, sizeof(stored_user), file) && fgets(stored_pass, sizeof(stored_pass), file)) {
            remove_newline(stored_user);
            remove_newline(stored_pass);
            if (strcmp(input_user, stored_user) == 0 && strcmp(input_pass, stored_pass) == 0) {
                valid = 1;
                break;
            }
        }
        if (valid) {
            printf("Login successful!\n");
            fclose(file);
            return 1;
        } else {
            printf("Invalid username or password. Try again!\n");
        }
    }
}

void execute_command(char *cmd) {
    char *args[MAX_LENGTH];
    char *token = strtok(cmd, " ");
    int i = 0, redirect_out = 0, redirect_in = 0, append_out = 0;
    char *outfile = NULL, *infile = NULL;
    while (token != NULL) {
        if (strcmp(token, ">>") == 0) {
            append_out = 1;
            token = strtok(NULL, " ");
            if (token != NULL) outfile = token;
        } else if (strcmp(token, ">") == 0) {
            redirect_out = 1;
            token = strtok(NULL, " ");
            if (token != NULL) outfile = token;
        } else if (strcmp(token, "<") == 0) {
            redirect_in = 1;
            token = strtok(NULL, " ");
            if (token != NULL) infile = token;
        } else {
            args[i++] = token;
        }
        token = strtok(NULL, " ");
    }
    args[i] = NULL;
    int saved_stdout, saved_stdin;
    if (redirect_out || append_out) {
        saved_stdout = dup(STDOUT_FILENO);
        int fd = open(outfile, O_WRONLY | O_CREAT | (append_out ? O_APPEND : O_TRUNC), 0644);
        if (fd < 0) {
            perror("Error opening output file");
            return;
        }
        dup2(fd, STDOUT_FILENO);
        close(fd);
    }
    if (redirect_in) {
        saved_stdin = dup(STDIN_FILENO);
        int fd = open(infile, O_RDONLY);
        if (fd < 0) {
            perror("Error opening input file");
            return;
        }
        dup2(fd, STDIN_FILENO);
        close(fd);
    }
    if (strcmp(args[0], "ls") == 0) {
        struct dirent *entry;
        DIR *dp = opendir(".");
        if (dp == NULL) {
            perror("ls error");
            return;
        }
        while ((entry = readdir(dp))) {
            printf("%s  ", entry->d_name);
        }
        printf("\n");
        closedir(dp);
    } else if (strcmp(args[0], "cd") == 0) {
        if (chdir(args[1]) != 0) perror("cd error");
    } else if (strcmp(args[0], "mkdir") == 0) {
        if (mkdir(args[1], 0755) != 0) perror("mkdir error");
    } else if (strcmp(args[0], "rmdir") == 0) {
        if (rmdir(args[1]) != 0) perror("rmdir error");
    } else if (strcmp(args[0], "rm") == 0) {
        if (remove(args[1]) != 0) perror("rm error");
    } else if (strcmp(args[0], "touch") == 0) {
        int fd = open(args[1], O_CREAT | O_WRONLY, 0644);
        if (fd < 0) perror("touch error");
        else close(fd);
    } else if (strcmp(args[0], "cat") == 0) {
        FILE *file = fopen(args[1], "r");
        if (!file) perror("cat error");
        else {
            char ch;
            while ((ch = fgetc(file)) != EOF) putchar(ch);
            fclose(file);
        }
    } else if (strcmp(args[0], "echo") == 0) {
        for (int j = 1; args[j] != NULL; j++) {
            printf("%s ", args[j]);
        }
        printf("\n");
    } else {
        printf("Unknown command: %s\n", args[0]);
    }
    if (redirect_out || append_out) {
        fflush(stdout);
        dup2(saved_stdout, STDOUT_FILENO);
        close(saved_stdout);
    }
    if (redirect_in) {
        dup2(saved_stdin, STDIN_FILENO);
        close(saved_stdin);
    }
}

int main() {
    if (access(USER_FILE, F_OK) != 0) register_user();
    if (verify_login()) {
        printf("\nWelcome to the Mini Linux OS Terminal!\n");
        char command[MAX_LENGTH];
        while (1) {
            printf("$ ");
            if (fgets(command, sizeof(command), stdin) == NULL) break;
            remove_newline(command);
            execute_command(command);
        }
    }
    return 0;
}
