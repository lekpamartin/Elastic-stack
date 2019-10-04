elasticsearch :
  curator:
    client:
      hosts: [ "10.0.0.1", "10.0.0.2" ]
      port: 9200
    logging:
      loglevel: 'INFO'
      logfile: /var/log/elasticsearc/curator.log
    actions:
      - action: delete_indices
        description: "Delete selected indices"
        options:
          continue_if_exception: False
          option1: value1
        filters:
          - filtertype: "*first*"
            filter_element1: value1
            filter_elementN: valueN
          - filtertype: "*second*"
            filter_element1: value1
