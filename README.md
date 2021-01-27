# Get-CtxAvailablesDGs
Connect to remote XenDesktop farm (CVAD) to obtain data about availability of Delivery groups

## Parameter DdcServers
    List of Delivery Controller(s) per farm. Can be more than one Delivery controller per farm.

## Parameter Credential
    Credentials to connect to remote server and XenDesktop farm (Read-Only)

## Requirements

## Output
    Return data in json format (data can be imported in influxDB)

![Get-CtxAvailablesDGs_output](https://user-images.githubusercontent.com/23212171/82840448-efb29380-9ed2-11ea-9941-36207550181b.png)

## Ideas for Grafana

![Get-CtxAvailablesDGs_grafana](https://user-images.githubusercontent.com/23212171/82840444-ec1f0c80-9ed2-11ea-9206-551c5db1f481.png)



