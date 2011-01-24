
rm -rf ../repo; mkdir ../repo; pushd ../repo; git init; popd;

for server in server/minecraft_server.0.2.1.jar \
server/minecraft_server.0.2.1_00.jar \
server/minecraft_server.0.2.2.jar \
server/minecraft_server.0.2.2_01.jar \
server/minecraft_server.0.2.3.jar \
server/minecraft_server.0.2.4.jar \
server/minecraft_server.0.2.5.jar \
server/minecraft_server.0.2.5_00.jar \
server/minecraft_server.0.2.5_01.jar \
server/minecraft_server.0.2.5_02.jar \
server/minecraft_server.0.2.6.jar \
server/minecraft_server.0.2.6_01.jar \
server/minecraft_server.0.2.6_02.jar \
server/minecraft_server.0.2.7.jar \
server/minecraft_server.0.2.8.jar \
server/minecraft_server.1.1_02.jar \
server/minecraft_server.1.2.jar \
server/minecraft_server.1.2_01.jar ;\

do \
    V=`echo $server | sed -e 's/^[^0-9]*//' -e 's/[.][^.]*$//'`; \
    bin/rename.sh $server; bin/decompile.sh; \
    pushd ../repo; git rm -rf *; unzip ../minecraft_server.src.zip; git add .; git commit -m$V; popd; \
done;
