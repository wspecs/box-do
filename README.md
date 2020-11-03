# box-do

Run the following in a wspecs box
```bash
cd ~
git clone https://github.com/wspecs/box-do.git
cd box-do
chmod +x build.sh
DO_ACCESS_KEY=key DO_SECRET_KEY=secret DO_REGION=nyc3 build.sh
cd ~
rm -rf box-do
```

Dependencies
```
box-functions
```
