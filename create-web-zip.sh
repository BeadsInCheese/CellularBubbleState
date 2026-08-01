#!/bin/sh
cd export

rm -r web-export
cp -r web/ web-export
sed 's/$IP/'"$(cat ip)"'/g' web-export/CBS-web.html > web-export/index.html

cd web-export
zip -r web-export-$(date -I) .
cd ..
mv web-export/web-export-* .
