说明文档
=======

## 环境搭建
全套环境可使用 Docker，不用手动安装 MySQL 和 Ruby 开发环境。
* Docker v20.10.x
* docker-compose v1.28.x
* Mysql 5.6+ 主从数据库，可使用Docker快速搭建环境

## 运行环境
* Step1: 配置数据库连接，打开 config/database.yml 文件，修改主从数据库的连接参数为你的
* Setp2: 配置并行进程数，打开 config/puma.rb 文件，修改 WEB_CONCURRENCY 和 RAILS_MAX_THREADS  
* Step3: 创建并启动容器
```bash  
docker-compose up
```
在程序跑起来后，做下一步的数据检查

* Step4: 在浏览器中打开 http://localhost:3000 ，这个是数据监控页面，如果有一行数据则表示运行成功，点击绿色按钮可让数据自动刷新。
或者使用终端指令确认有返回json数据
```bash 
curl -XGET 'http://localhost:3000/api/dashboard'
```

## Postman测试并发 (顺序请求) 
* Postman可以选择接口集合，然后执行 "Run collection"，设置总执行回合即可测试。可下载 [接口集合文件](https://raw.githubusercontent.com/kdstarter/master-slave-db-demo/master/public/demo/DB2-Tester.postman_collection.json)，然后导入到 Postman

## ab工具做压力测试 (并行请求) 
'Authorization: 1-1000' 表示每次接口请求的用户ID为1到1000中的随机一个
* 综合压力测试，随机分发到以下接口
```bash
ab -c 50 -n 500 -m POST -H 'Authorization: 1-1000' 'http://localhost:3000/api/dashboard/mock_mix_action?scope=my'
```
这时dashboard页面示范数据如下图  
![dashboard页面示范](https://raw.githubusercontent.com/kdstarter/master-slave-db-demo/master/public/demo/db_dashboard.png)

* 以下是分别测试单个接口  
获取我的商品列表
```bash
ab -c 100 -n 1000 -m GET -H 'Authorization: 1-1000' 'http://localhost:3000/api/products?scope=my'
```
发布一个我的商品
```bash
ab -c 100 -n 1000 -m POST -H 'Authorization: 1-1000' 'http://localhost:3000/api/products'
```
获取我的订单列表
```bash
ab -c 100 -n 1000 -m GET -H 'Authorization: 1-1000' 'http://localhost:3000/api/orders?scope=my'
```
创建待付款的订单
```bash
ab -c 50 -n 1000 -m POST -H 'Authorization: 1-1000' 'http://localhost:3000/api/orders'
```
随机给订单付款或关闭
```bash
ab -c 50 -n 500 -m PUT -H 'Authorization: 1-1000' 'http://localhost:3000/api/orders/random_id'
```

