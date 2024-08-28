# Values Schema File

[TOC]


Values Schemas were added into Helm v3 in order to validate the final helm merged values.yaml file against the merged JSON schemas.

The schema is automatically validated/checked through the use of the Helm install, upgrade, lint and template commands.

It allows us to achieve the following:

- Requirement checks (in order to check if a variable has been set).


- Type Validation (checking if a key is of a correct type)


- Range Validation (checking if a value is between a certain number range)


- Constraint Validation (checking for example if a URL has the format http(s)://<host>:<port> or if a pull policy is present)

> **Note:** To learn more about the use of Values Schemas, please refer to the following [Json Schema Documentation](https://json-schema.org/)


Given an example values file:

```
image:
  repository: my-docker-image
  pullPolicy: IfNotPresent
```

The corresponding values schema would be the following:

```
{
  "$schema": "http://json-schema.org/schema#",
  "type": "object",
  "required": [
    "image"
  ],
  "properties": {
    "image": {
      "type": "object",
      "required": [
        "repository",
        "pullPolicy"
      ],
      "properties": {
        "repository": {
          "type": "string",
          "pattern": "^[a-z0-9-_]+$"
        },
        "pullPolicy": {
          "type": "string",
          "pattern": "^(Always|Never|IfNotPresent)$"
        }
      }
    }
  }
}
```


In the example above, we can see a list of parameters that are needed when creating a values schema:

| Parameter  | Description                                                                                               | Default   |
|------------|-----------------------------------------------------------------------------------------------------------|-----------|
| $schema    | Declares which dialect of JSON schema, the schema was written for.                                        |           |
| properties | Key-Value pairs of an object that are defined. It is an object, where each key is the name of a property. | ConfigMap |
| required   | Also you to define which key-value pairs must be enforced/required.                                       |           |
| type       | Specifies the data type of the property for the schema (Boolean, String, integer etc.)                    |           |


Given the example values schema above, below is the process of adding a Key-Value Pair to the schema:

Let's say we have defined a new value (nameOverride) which is of type string, is required and has a default value of "Default Chart Name" that allows us to overwrite the existing Chart's name.


Firstly, let's say we have a values.yaml file within our chart, we must add this nameOverride value into the values.yaml with the default string "Default Chart Name". As it has no dependency on the image object, we can put this value-key pair on a new line.

> **Note:** These values within values.yaml are default configuration values and will not been seen by the customer. The site_values.yaml will contain customer specified values that will be seen and filled in by the customer.

values.yaml:

```
image:
  repository: my-docker-image
  pullPolicy: IfNotPresent

nameOverride: "Default Chart Name"
values1: 0
values2: 0
```

site_values.yaml:

```
nameOverride: "Customer's Chart"
values1: 20
```

This would result in the following merged values.yaml file:

```
image:
  repository: my-docker-image
  pullPolicy: IfNotPresent

nameOverride: "Customer's Chart"
values1: 20
values2: 0
```


Now that we have the complete merged values.yaml file, we must update the schema in order to validate the new merged values.yaml file:

```
{
  "$schema": "http://json-schema.org/schema#",
  "type": "object",
  "required": [
    "image"
  ],
  "properties": {
    "image": {
      "type": "object",
      "required": [
        "repository",
        "pullPolicy"
      ],
      "properties": {
        "repository": {
          "type": "string",
          "pattern": "^[a-z0-9-_]+$"
        },
        "pullPolicy": {
          "type": "string",
          "pattern": "^(Always|Never|IfNotPresent)$"
        }
      }
    },
    "nameOverride" : {
      "type": "string"
    }
  },
  "required": [
    "nameOverride",
    "values1",
    "values2",
    "image"
  ]
}
```

The resulting values schema above completes validation for the merged values.yaml above with required values for image, values1, values2 and nameOverride.

> **Note:** The merged values.yaml will contain values from multiple values.yaml (Default configuration values from multiple different charts - A Value Inheritance is followed in this case) and a site_values.yaml (That the customer will see and will need to fill in).


The following Inheritance is followed when merging values from multiple values.yaml files:

1) Helmfile Command Line

2) Site Values

3) Helmfile Values

4) Helmfile GoTPL

5) Application Values

6) Microservice Values


Let's say we have a Microservice - MyMicroservice which contains the following values.yaml file:
```
numberOfItems: 20
numberOfItemsInCart: 2
numberOfItemsLeftOver: 16
```

MyMicroservice is stored within an application chart - MyApplication which contains the following values.yaml file:

```
numberOfItems: 20
numberOfItemsInCart: 4
```

Now imagine the application chart (MyApplication) is stored as a dependency within another Application (OverridingApplication) which contains the following values.yaml file:

```
numberOfItems: 30
```

This would result in the following as the merged values.yaml file created by Helm (Which showcases the Inheritance Priority):

```
numberOfItems: 30
numberOfItemsInCart: 4
numberOfItemsLeftOver: 16
```