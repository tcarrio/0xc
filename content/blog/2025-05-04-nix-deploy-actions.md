+++
title = "Nix Deploy Actions"
slug = "nix-deploy-actions"
date = 2025-05-04

[extra]
author = "Tom Carrio"

[taxonomies]
tags = ["ci", "nix", "github"]
+++

This topic is not a new one for those who have been following Nix. Between the Cachix Nix Action and the Determine Nix Installer Action, there are not only options but enterprise-level backing for Nix on GitHub. This post will focus on a specific example: _How I stabilized my CI deployment processes, reduced configuration drift between CI and local development, and fixed an issue that left my blog CI broken for 10 months.

## The Situation

I was making use of the [Zola GitHub Action](https://github.com/shalzz/zola-deploy-action) (props to [@shalzz](https://github.com/shalzz)) when I initially started publishing my Zola-based blog. This was very simple to get started, and worked well for me for several months. But then one day, while the Zola binary on my system was working great, the CI action started to utilize a different version that was incompatible with my configuration as it was. This brought my deployment process to its knees, and I was reminded again of the random pain you will often suffer with systems that don't have strong consistency across environments.

> *It works on my machine 🤷*

## Reproducible Development Shells

I am already making use of Nix for a development environment. A little bit of `direnv`, Nix flakes, and every time I pull my repository down, regardless if it's my Linux or macOS system, as long as I have the Nix tooling configured I will pull down the exact same development environment I had when I last worked on the project. It's truly an amazing feat. Even Docker doesn't provide *reproducibility*, it gets you pretty far though. But here, just the configuration definition and the use of flakes and the locked inputs, I will always resolve the same environment.

## Reproducible Packages

My Nix flake defined a development shell with the packages I need, with consistency in versioning and PATH. Now I wanted to apply the same package consistency but for a command I would run. In a Nix flake, you can define a package in many different ways. In this case, it being a shell script, I was going to make use of the `makeWrapper` package's `wrapProgram` command and the `writeScriptBin` package in Nix to take a Bash script, provide a consistent PATH of packages, and ensure the shebangs are patched to use the correct version of the shell as well. Everything would be controlled, exactly to what I need.

## Initial Version: Fork It!

My first version, largely to prove that it works, simply forked the source of the Zola action's `entrypoint.sh`. After all, it's not like anything was really wrong with the script, just the environment it executes in. Taking this verbatim (with license and reference to upstream tacked in the header for good measure), I can use Nix to simply setup the runtime. I provide it the necessary `coreutils`, `git`, and `zola` of course. I condense the logic largely to make the actual package line more digestible:

```nix
bundleShellScript { name = "deploy.sh"; filePath = ./ci/deploy.sh; buildInputs = with pkgs; [ git zola coreutils ]; }
```

How does this work? Well, it orchestrates a bit of the wrapping necessary for the command. Let's see the function definition I wrote:


```nix
{ name, filePath, buildInputs, ... }:
let
    command = (pkgs.writeScriptBin name (builtins.readFile filePath)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
    });
in pkgs.symlinkJoin {
    inherit name;
    paths = [ command ] ++ buildInputs;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
```

Now I can give it any file reference and build inputs necessary for the command and we'll get a packaged command with all the necessary environment configuration to resolve the exact `zola`, `git`, etc. that I need.

## The Diff: GitHub Workflow Edition

So how much change was necessary on the GitHub Action workflow I was using? Well, I needed to ensure Nix was installed, for starters. But beyond that, the environment variables I pass in remain the same, it's primarily *how I invoke the command* that differs.

```diff
diff --git a/.github/workflows/publish.yaml b/.github/workflows/publish.yaml
index 24b5d99..b1c2bcb 100644
--- a/.github/workflows/publish.yaml
+++ b/.github/workflows/publish.yaml
@@ -11,12 +11,10 @@ jobs:
     runs-on: ubuntu-latest
     if: github.ref != 'refs/heads/main' && github.ref != 'refs/heads/gh-pages'
     steps:
       - name: Checkout main
         uses: actions/checkout@v3.0.0
         with:
           submodules: true
+      - uses: DeterminateSystems/nix-installer-action@main
       - name: Build only
-        uses: shalzz/zola-deploy-action@master
+        run: nix run .#deployAction
         env:
           BUILD_ONLY: true
           BUILD_FLAGS: --drafts
@@ -25,12 +23,10 @@ jobs:
     runs-on: ubuntu-latest
     if: github.ref == 'refs/heads/main'
     steps:
       - name: Checkout main
         uses: actions/checkout@v3.0.0
         with:
           submodules: true
+      - uses: DeterminateSystems/nix-installer-action@main
       - name: Build and deploy
-        uses: shalzz/zola-deploy-action@master
+        run: nix run .#deployAction
         env:
           PAGES_BRANCH: gh-pages
           GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Yes. It is actually just 6 lines of code changed to accomplish this. My commit ended up catching some formatting fixes and updating the version for the checkout action, but this captures that actual requirements for migrating to using a Nix command instead of a GitHub Action. It is **wildly simple**.

1. Install Nix
2. Run Nix commands
3. ???
4. Profit
