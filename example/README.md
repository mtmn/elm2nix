# Example

An example Elm web application that showcases the possibilities with `dwayne/elm2nix`.

## Usage

Enter the development environment:

```bash
nix develop
```

This gives you access to Elm related tooling as well as `elm2nix`.

## FAQ

### How was `elm.lock` generated?

```bash
elm2nix lock elm.json review/elm.json
```

### What derivations are available?

There are the derivations for building various instances of the example Elm web application and there are derivations that help you inspect the inner workings of the `buildElmApplication` derivation.

#### The example Elm web application derivations

- `example` - Uses a normal `elm make` compilation
- `debuggedExample` - Compiles with `elm make --debug`
- `formattingCheckedExample` - Shows `elm-format` usage
- `elmSafeVirtualDomExample` - Shows how to make use of [`lydell/elm-safe-virtual-dom`](https://github.com/lydell/elm-safe-virtual-dom)
- `elmSafeVirtualDomElmCssExample` - Shows how to make use of `lydell/elm-safe-virtual-dom` with [`lydell/html`](https://github.com/lydell/html) replaced with [`omnibs/elm-css`](https://github.com/omnibs/elm-css/tree/safe)
- `testedExample` - Shows `elm-test` usage
- `reviewedExample` - Shows `elm-review` usage
- `optimizedExample` - Compiles with `elm make --optimize`
- `optimized2Example` - Compiles with `elm-optimize-level-2`
- `optimized3Example` - Compiles with `elm-optimize-level-2` with the `--optimize-speed` flag
- `combined1Example` - Shows the support for multiple entries
- `combined2Example` - Shows how multiple entries with `elm-optimize-level-2` is disallowed
- `minifiedExample` - Shows minification with [Terser](https://terser.org/)
- `compressedExample` - Shows compression with [gzip](https://www.gnu.org/software/gzip/) and [brotli](https://github.com/google/brotli)
- `reportedExample` - [Shows a report](https://guide.elm-lang.org/optimization/asset_size#scripts) in the logs about the changes in your file size due to minification and compression
- `hashedExample` - Shows the support for content hashing
- `finalExample` - Equivalent to `hashedExample` but specified in one go

#### The internal derivations

- `exampleFetchElmPackage` - Fetches version `1.0.2` of the `elm/browser` package
- `exampleDotElmLinks` - Creates the Elm cache tailored for the example Elm web application
- `lydellBrowser` - A patched version of `elm/browser` at version `1.0.2`
- `lydellHtml` - A patched version of `elm/html` at version `1.0.1`
- `lydellVirtualDom` - A patched version of `elm/virtual-dom` at version `1.0.5`
- `omnibsElmCss` - A patched version of `rtfeldman/elm-css` at version `18.0.0`

### How to build the derivations?

I usually use `nix build .#nameOfDerivation`. Add `-L` to view the logs in realtime and if the build fails I usually rerun it with `--keep-failed` to be able to inspect the build directory.

You can view the build output in the `result` directory.

### How to view the scripts?

A scripts attribute set is included in the outputs of the `flake.nix` which allows you to inspect how the helper scripts work. You can view them as follows:

```
nix repl
> :lf .
> :p outputs.scripts.x86_64-linux.examplePrepareElmHomeScript
> :p outputs.scripts.x86_64-linux.exampleSymbolicLinksToPackagesScript
> :p outputs.scripts.x86_64-linux.installLydellBrowserScript
> :p outputs.scripts.x86_64-linux.installLydellHtmlScript
> :p outputs.scripts.x86_64-linux.installLydellVirtualDomScript
> :p outputs.scripts.x86_64-linux.installOmnibsElmCssScript
```
