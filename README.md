Build:

Mac OS X, 32 bit, Node-Webkit 0.8.6:
```
rm -rf data/*
npm install sqlite3 --build-from-source --runtime=node-webkit --target_arch=ia32 --target=0.8.6
mv node_modules/sqlite3/lib/node-webkit-v0.8.6-darwin-ia32 node_modules/sqlite3/lib/node-webkit-v11-darwin-ia32
sh build.sh
```

Mac OS X, x64, node-webkit 0.10.4
```
npm install sqlite3 --build-from-source --runtime=node-webkit --target_arch=ia64 --target=0.10.4
cd node_modules/sqlite3
node-pre-gyp build --runtime=node-webkit --target=0.10.4
mv node_modules/sqlite3/lib/node-webkit-v0.10.4-darwin-x64 node_modules/sqlite3/lib/node-webkit-v14-darwin-x64
```

Then copy app.nw into `node-webkit.app/Contents/Resources/app.nw`.