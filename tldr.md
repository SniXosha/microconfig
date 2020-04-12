### #includes
You can extract common parts of configuration to a dedicated component and reuse it via `#include`

`components/common/common-monitoring/application.yaml`
```yaml
management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: info, health, prometheus
```

`components/orders/orders-service/application.yaml`
```yaml
#include common-monitoring

spring:
  application:
    name: orders-service

server:
  context: /api
```

`resulting orders-service application.yaml`
```yaml
management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: info, health, prometheus

spring:
  application:
    name: orders-service

server:
  context: /api
```


### ${placeholders}
Instead of duplicating value of a property you can reference it with a placeholder. 
You can reference a specific component with `${name@...}` or current component graph with `${this@...}`

`components/common/urls/application.yaml`
```yaml
orders: https://orders.example.com

payments: http://payments.example.com
```

`components/orders/orders-service/application.yaml`
```yaml
...
server:
  context: /api
```

`components/orders/orders-ui/application.yaml`
```yaml
backend:
  host: ${urls@orders}
  path: ${orders-service@server.context}
  
log:
  filename: ${this@spring.application.name}.log
  
spring:
  application:
    name: orders-ui  
```

`resulting orders-ui application.yaml`
```yaml
backend:
  host: https://orders.example.com
  path: /api

log:
  filename: orders-ui.log

spring:
  application:
    name: orders-ui
```

### #var
You can have special properties `#var key: value` that don't go into final result but can be referenced via placeholders during generation.

`components/common/common-service/application.yaml`
```yaml
#include common-monitoring

spring:
  application:
    name: ${this@appName}
```

`components/common/database/application.yaml`
```yaml
spring:
  datasource:
    username: postgres
    password: postgres
    url: jdbc:postgresql://postgres.local:5432/${this@dbName}
```

`components/orders/payment-service/application.yaml`
```yaml
#include common-service, database

#var appName: payment-service
#var dbName: payments
```

`resulting payment-service application.yaml`
```yaml
management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: info, health, prometheus

spring:
  application:
    name: payment-service
  datasource:
    username: postgres
    password: postgres
    url: jdbc:postgresql://postgres.local:5432/payments
```

### #{expressions}
If you need dynamic properties you can use expressions. It's convenient for math operations but can do a lot more. 
You can even have placeholders inside expressions.

`components/orders/payment-service/application.yaml`
```yaml
...

server:
  # 3 minutes timeout in milliseconds
  timeout: #{1000 * 60 * 3 }                     
  minThreads: 50
  # max threads is 10 threads extra
  maxThreads: #{ ${this@server.minThreads} + 10 }
```

`resulting payment-service application.yaml`
```yaml
...

server:
  timeout: 180000
  minThreads: 50
  maxThreads: 60
```  

### env specific config
For each component you can write base configuration in base file and then add environment specific values. For example:
* `application.yaml` - `base` configuration
* `application.dev.yaml` - `dev` environment specific properties
* `application.prod.yaml` - `prod` environment specific properties 

`components/common/common-log/application.yaml`
```yaml
log:
  level:
    root: DEBUG
```

`components/common/common-log/application.prod.yaml`
```yaml
log:
  level:
    root: INFO
```

`components/orders/payment-gateway/application.yaml`
```yaml
#include common-service, common-log

#var appName: payment-gateway
```

`components/orders/payment-gateway/application.dev.yaml`
```yaml
payments:
  provider:
    url: http://payments-provider-mock.local
```

`components/orders/payment-gateway/application.prod.yaml`
```yaml
payments:
  provider:
    url: https://payments-provider.com
```


`resulting payment-gateway application.yaml for dev environment`
```yaml
...

log:
  level:
    root: DEBUG

payments:
  provider:
    url: http://payments-provider-mock.local
```  

`resulting payment-gateway application.yaml for prod environment`
```yaml
...

log:
  level:
    root: INFO

payments:
  provider:
    url: https://payments-provider.com
```  

### yaml/properties
Microconfig supports yaml and properties formats for application configuration interchangeably. You can do #includes and ${placeholders} from one to another.

`components/props/config.properties`
```properties
spring.application.name=service
```

`components/yaml/application.yaml`
```yaml
#include props

server:
  port: 80
```

`resulting yaml application.yaml`
```yaml
server:
  port: 80

spring:
  application:
    name: service
```  

### different config types
You can have different configuration types for each component. It is convenient to store you deploy configuration together with application config.
You can define your own types in `microconfig.yaml`

```yaml
configTypes:
  - app:
      resultFileName: application
      sourceExtensions:
        - .yaml
        - .properties
  - helm:
      resultFileName: values
      sourceExtensions:
        - .helm
```

`components/common/helm-probes/values.helm`
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health
    port: http

readinessProbe:
  httpGet:
    path: /actuator/health
    port: http
```

`components/payments/payment-gateway/values.helm`
```yaml
#include helm-probes

image: "payment-gateway:latest"

replicas: 1

ingress:
  host: http://payment-gateway.local
  annotations:
    "ingress.class": nginx
```

`generated version of payment-gateway values.yaml`
```yaml
image: "payment-gateway:latest"

replicas: 1

ingress:
  host: http://payment-gateway.local
  annotations:
    "ingress.class": nginx

livenessProbe:
  httpGet:
    path: /actuator/health
    port: http

readinessProbe:
  httpGet:
    path: /actuator/health
    port: http
```

#### cross type reference
Placeholders between different config types with additional syntax `${type::component@...}`

`components/payments/payment-service/application.yaml`
```yaml
...

gateway:
  url: ${helm::payment-gateway@ingress.host}
```

`generated version of payment-service application.yaml`
```yaml
...
gateway:
  url: http://payment-gateway.local
```



### templates
