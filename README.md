# microservices as controllers

this is an attempt to bring a concept of microservices to controllers in web app.

# kafka

```
$ bin/zookeeper-server-start.sh config/zookeeper.properties
$ bin/kafka-server-start.sh config/server.properties
```

*optional*

```
$ bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic http-request --from-beginning
$ bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic http-response --from-beginning
```



# how to run

```
$ ruby driver_server.rb
$ ruby driver_controller.rb
$ curl -i localhost:3000/items
```

