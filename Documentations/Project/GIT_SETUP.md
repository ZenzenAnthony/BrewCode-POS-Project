# Git Setup Guide for BrewCode POS Project

This guide will help you connect your local Git repository to a remote repository on GitHub or other Git hosting services.

## Connecting to a Remote Repository

### 1. Create a Repository on GitHub

1. Go to [GitHub](https://github.com/) and sign in to your account
2. Click on the "+" icon in the top-right corner and select "New repository"
3. Name your repository (e.g., "BrewCode-POS")
4. Add a description (optional)
5. Choose whether to make it public or private
6. **Do not** initialize the repository with a README, .gitignore, or license
7. Click "Create repository"

### 2. Connect Your Local Repository to GitHub

After creating the repository, GitHub will show you commands to connect your local repository. Run the following commands in your terminal:

```powershell
# Navigate to your project directory (if not already there)
cd "C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project"

# Add the remote repository
git remote add origin https://github.com/YourUsername/BrewCode-POS.git

# Push your local repository to GitHub
git push -u origin master
```

Replace `YourUsername` with your actual GitHub username and `BrewCode-POS` with your repository name.

## Basic Git Commands

Here are some basic Git commands you'll use frequently:

### Check Status

```powershell
git status
```

### Add Changes

```powershell
# Add specific file
git add filename.ext

# Add all changes
git add .
```

### Commit Changes

```powershell
git commit -m "Your commit message here"
```

### Push Changes to Remote

```powershell
git push
```

### Pull Changes from Remote

```powershell
git pull
```

### Create a New Branch

```powershell
git checkout -b branch-name
```

### Switch Branches

```powershell
git checkout branch-name
```

## Best Practices

1. **Commit Often**: Make small, focused commits that address specific changes
2. **Write Good Commit Messages**: Be clear and descriptive about what changes were made
3. **Pull Before Push**: Always pull the latest changes before pushing to avoid conflicts
4. **Use Branches**: Create separate branches for new features or bug fixes
5. **Review Changes**: Use `git diff` to review your changes before committing

## Git GUI Clients

If you prefer a graphical interface, consider using these Git clients:

- [GitHub Desktop](https://desktop.github.com/)
- [GitKraken](https://www.gitkraken.com/)
- [Sourcetree](https://www.sourcetreeapp.com/)
- [Visual Studio Code Git Integration](https://code.visualstudio.com/docs/editor/versioncontrol)
