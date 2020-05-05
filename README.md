This repo demonstrates an issue where parcel won't pickup changes to FFI .js code.

Initial setup:
```
git clone https://github.com/milesfrain/ffi-reload.git
cd ffi-reload
spago build
parcel src/index.html --open
```

Open the browser's console logs and note this output
> JS v1 Purs v1

Edit `src/Main.js` to print `JS v2`.

Re-run `spago build` and note browser's console logs are updated to:
> JS v2 Purs v1

Edit `src/Main.js` to print `JS v3`.

Re-run `spago build` and note that `parcel` does not re-bundle or refresh the page, and logs remain as:
> JS v2 Purs v1

Edit `src/Main.purs` to print `Purs v4`.
Re-run `spago build` and note:
* Parcel rebundles
* Browsers log only updated to reflect changes in purs files, but not FFI .js files.
> JS v2 Purs v4

Changes to .js FFI files are ignored because the `parcel` filewatcher looses track of `output/**/foreign.js`, which are copied atomically by `purs` from `src/**.js`.

Changes to .purs files are always picked-up by parcel because their resulting .js files are written to directly, instead of copied over.

`inotifywait` shows the difference in more detail. To see for yourself:
1. Edit both `src/Main.purs` and `src/Main.js`.
2. Launch `inotifywait -r -m output/Main`
3. Run `spago build`

Here is the problematic atomic copy:
```
output/Main/ CREATE .copyFile2908-0.tmp
output/Main/ OPEN .copyFile2908-0.tmp
output/Main/ MODIFY .copyFile2908-0.tmp
output/Main/ CLOSE_WRITE,CLOSE .copyFile2908-0.tmp
output/Main/ ATTRIB .copyFile2908-0.tmp
output/Main/ MOVED_FROM .copyFile2908-0.tmp
output/Main/ MOVED_TO foreign.js
```

This style of file editing is fine:
```
output/Main/ OPEN index.js
output/Main/ MODIFY index.js
output/Main/ MODIFY index.js
output/Main/ CLOSE_WRITE,CLOSE index.js
```