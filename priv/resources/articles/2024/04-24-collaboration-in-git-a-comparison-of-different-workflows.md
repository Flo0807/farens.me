%{
  slug: "collaboration-in-git-a-comparison-of-different-workflows",
  title: "Collaboration in Git: A comparison of different workflows",
  description: "Choosing the right Git workflow is crucial for the success of a project. This article breaks down the nuances of different Git workflows and provides insight into the pros and cons of each.",
  published: true
}
---

Choosing the right Git workflow is crucial for the success of a project. This article breaks down the nuances of different Git workflows and provides insight into the pros and cons of each.

## Introduction

Git is a distributed version control system that is mainly used in software development to track changes in source code during the development process. It was created by by Linus Torvalds in 2005 to manage the Linux kernel development. Git is a free and open-source tool that is used by millions of developers worldwide. Altough it is mainly used in software development, Git can be used to track changes in any set of files.

No technology has revolutionized the way developers work together quite like Git. The [stack overflow developer survey in 2022](https://survey.stackoverflow.co/2022) showed that almost 94% of developers use Git as their version control system. Git has become the de facto standard for version control systems. Thats why it is important to understand how to work with Git and how to collaborate with other developers.

This articles assumes that you are already familiar with Git and have a basic understanding of how it works. If you are new to Git, you can learn more about it in the [official Git documentation](https://git-scm.com/doc).

## The Problem

When working on a software project with multiple developers, it is important to have a system in place to manage changes to the code base. Without a version control system, developers would not be able to collaborate properly. A version control system like Git makes it easy to track changes to the codebase, collaborate with other developers, and manage the development process. 

However, working with Git can be challenging, especially when working with multiple developers on the same codebase. Git only provides a set of tools for developers to use, but it does not provide guidelines on how to use them and how to work together. This is where Git workflows come in.

## What is a Git workflow?

A Git workflow is a set of rules that define how developers work with Git. It defines how changes are made, reviewed, and integrated into the codebase. There are many different Git workflows, but the most popular are the Gitflow, feature branch, and forking workflow.

## Why is a Git workflow Important?

You may be wondering why you need a Git workflow at all. Why not just let developers decide how they want to work with Git?

The answer is simple: the Git workflow used in a project has an impact on the success of the project. The reason is that a suitable Git workflow helps developers collaborate more effectively, reduces the risk of conflicts and errors, and makes it easier to work together. 

The prerequisite is that the Git workflow is well-defined, followed by all developers, and meets the needs of the project. This is why it is important to choose the right Git workflow for your project. In the following sections, we will provide an overview of the most popular Git workflows and help you choose the right one for your project.

## Git workflows

### Centralized workflow

Propably the simplest Git workflow is the centralized workflow. In this workflow, there is a single central repository that all developers work from. Developers clone the repository to their local machine, make changes, and push them back to the central repository. This workflow is suitable for small teams or projects where there is no need for complex branching and merging. In addition, it is easy to set up and understand, making it ideal for beginners or teams that are new to Git. Especially for teams that are used to working with a centralized version control system like Subversion, the centralized workflow is a good starting point.

However, the centralized workflow has some limitations. As there are no branches, conflicts will occur frequently when multiple developers are involved. Therefore, the centralized workflow is not suitable for large beginner teams.

A typical centralized workflow looks like this:
- Clone the central repository to your local machine.
- Make changes to the code.
- Push the changes to the central repository.

### Gitflow workflow

Probably the most popular Git workflow is the Gitflow workflow. It was created by Vincent Driessen in 2010 and has since become the standard for many software development teams. The Gitflow workflow is based on the idea of using branches to manage the development process. The workflow itself defines a set of branches and rules for how to use them. Gitflow provides a clear structure for how changes are made, reviewed, and integrated into the code base.

A list of branches along with their purpose in the Gitflow workflow:
- `main` branch: Contains the latest stable version of the code base. Used for production releases.
- `develop`  branch: Contains the latest development version of the code base. Used for integrating new features and bug fixes.
- Feature branches: Created from the `develop` branch and used to develop new features.
- Release branches: Created from the `develop` branch and used to prepare a new release.
- Hotfix branches: Created from the `main` branch and used to fix critical bugs in the production code.

In Gitflow, the team works with multiple branches. This allows developers to work on different features and bug fixes at the same time, without interfering with each other. In addition, code reviews can be done on the feature branches before they are merged into the `develop` branch. This helps to catch bugs and errors early in the development process. In addition, it is possible to fix critical bugs in the production code without having to include new features that are still in development because of the separation of the `main` and `develop` branches. 

However, the Gitflow workflow is more complex than the centralized workflow and requires more discipline from developers. It is important that all developers follow the rules of the workflow and use the correct branches for their changes. For small teams or projects with simple requirements, the Gitflow workflow may be too complex.

Also, the Gitflow workflow can lead to long-lived branches, which can make it difficult to merge changes back into the main codebase. This can lead to conflicts and errors, especially if the branches are not kept up to date with the latest changes in the codebase. Long-lived branches also make it difficult to perform continuous integration and continuous deployment, because changes are not merged back into the main codebase frequently. Typically, you do not perform continuous integration and continuous deployment using the Gitflow workflow.

A typical Gitflow workflow looks like this:
- Create a new branch from the `develop` branch to start working on a new feature.
- Make changes to the code in the new branch.
- When the feature is complete, merge the branch into the `develop` branch.
- Once the `develop` branch is stable, create a new release branch from the `develop` branch.
- Make any necessary changes to the code on the release branch.
- When the release is complete, merge the release branch into the `main` and `develop` branches.
- If a critical bug is found in the production code, create a new hotfix branch from the `main` branch, and merge it back into the `main` and `develop` branches.

Due to the complexity and overhead of the Gitflow workflow, it is usually not suitable for web development projects that often require continuous integration and continuous deployment. The Gitflow workflow is more appropriate for projects with long release cycles, such as desktop applications or embedded systems.

However, because of its popularity, Gitflow is used by many software development teams for all kinds of projects.

Read more about the Gitflow workflow in the [original blog post](https://nvie.com/posts/a-successful-git-branching-model/) by Vincent Driessen.

### Feature branch workflow

A more modern workflow that is a mix between the centralized and Gitflow workflow is the feature branch workflow. In this workflow, every new change begins by creating a new branch. There are no strict rules about how to use branches like in Gitflow, but the general idea is to create a new branch for every new feature or bugfix. Each branch is created based on the latest version of the codebase and is used to make changes. When the changes are complete, the branch is merged back into the main codebase.

Typically, feature branches are short-lived. This reduces the risk of conflicts and bugs. Most teams also perform code reviews on feature branches before merging them back into the main codebase.

A typical Gitflow workflow looks like this
- Create a new branch based on the latest version of the codebase.
- Make changes to the code on the new branch.
- When the changes are complete, merge the branch back into the main codebase.

The feature Branch workflow is suitable for various types of projects, as it provides a good balance between the simplicity of the centralized workflow and the complexity of the Gitflow workflow, but it may not be suitable for projects that require continuous integration and deployment because changes are not always merged back into the main codebase quickly, even though the goal is to keep branches as short-lived as possible.

### Trunk-based workflow

In the trunk-based workflow, there is a single main branch called trunk (or simply main), which contains the latest version of the code base. Developers clone the trunk to their local machine, make changes, and push them back to the trunk. This workflow is very similar to the centralized workflow, but while the centralized workflow is often used by beginners, the trunk-based workflow is used by more experienced developers and can also be used by larger teams. In addition, the trunk-based workflow defines a set of rules and guidelines for how to work with the trunk and how to develop new features or bug fixes.

As only one branch is used in the trunk-based workflow, it requires responsibility and discipline from the teamn. It is important that each developer frequently commits to the trunk and keep changes as small as possible. The test coverage should be high to ensure that changes do not introduce bugs or errors as they are integrated directly into the trunk.

The trunk-based workflow is often used in projects that require continuous integration and deployment. The deployment process is often automated and each push to the trunk triggers a build and deployment process. When working on new features, the workflow often requires the use of feature flags to hide unfinished features. This allows developers to work on new features without affecting the production environment.

The trunk-based workflow also forces developers to perform code reviews synchronously, because changes are pushed directly to the trunk and changes can not be reviewed later on in a dedicated pull request like in other workflows. This enforces collaboration and communication between team members and prevents long-lived pull requests that wait for review.

A typical trunk-based workflow looks like this:
- Clone the trunk to your local machine.
- Make changes to the code.
- Push the changes to the trunk.

The main benefit of the trunk-based workflow is that it eliminates the *merge hell* that can occur when working with multiple long-lived branches that need to be merged into the main branch. This significantly reduces release cycle time. It also encourages collaboration and communication between team members and ensures that changes are integrated into the codebase frequently. However, the trunk-based workflow requires discipline and responsibility from the team and may not be suitable for beginners or teams that are new to Git.

### Forking workflow

The forking workflow is mainly used in open source projects or projects with external contributors. In this workflow, there is a central repository that contains the main codebase and each contributor has their own fork of the repository. Contributors clone their fork to their local machine, make changes and commit back to their fork. When the changes are complete, they create a pull request to merge the changes back into the main codebase.

A typical forking workflow looks like this:
- Fork the central repository to your own account.
- Clone your fork to your local machine.
- Make changes to the code.
- Push the changes to your fork.
- Create a pull request to merge the changes into the main / original codebase.

The forking workflow provides a clear separation between the main codebase and contributions from external contributors. This makes it easy to restrict access to the main repository. Maintainers do not need to grant access to the main repository, since contributors can work on their own fork. This is why the forking workflow is often used in open source projects, where many external contributors are involved.

## Which Git workflow to choose?

Choosing the right Git workflow for your project depends on many factors, such as the size of your team, the complexity of your project, and your development process. Here are some guidelines to help you choose the right Git workflow for your project:

- For small teams or projects with simple requirements, the centralized workflow is a good place to start. It is easy to set up and understand, making it ideal for beginners or teams new to Git. Especially for teams that are used to working with a centralized version control system before.
- For medium to large teams or projects with complex requirements and long release cycles, the Gitflow workflow is suitable. It provides a clear structure for how changes are made, reviewed, and integrated into the code base. 
- For all kind of projects that does not require "real" CI/CD, the feature branch workflow may a good choice. It provides a good balance between the simplicity of the centralized workflow and the complexity of the Gitflow workflow.
- For more experienced developers and teams, the trunk-based workflow may be appropriate. It reduces release cycle time, allows real continuous integration and deployment, and can greatly increase development speed.
- For open source projects or projects with external contributors, the forking workflow is the way to go. It provides a clear separation between the main codebase and contributions from external contributors.

It is important to note that above guidelines and workflows from this article are not set in stone. Of course, you may customize workflows or even think of new workflows that better suit your project. They key is to find a workflow that works for your team and your project.

## Conclusion

In this article, we have provided an overview of the most popular Git workflows. We have discussed the pros and cons of each workflow and provided some guidelines to choose the right Git workflow for your project. Let me know what workflow you use in your project.
