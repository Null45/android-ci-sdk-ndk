### Continous Integration (CI) for Android apps on GitLab

## Sample usages
### GitLab
*.gitlab-ci.yml*

```yml
image: hantrungkien/android-ci-sdk-ndk:latest

before_script:
    - export GRADLE_USER_HOME=`pwd`/.gradle
    - mkdir -p $GRADLE_USER_HOME
    - chmod +x ./gradlew

cache:
  key: "$CI_COMMIT_REF_NAME"
  paths:
     - .gradle/

stages:
  - build
  - test

build:
  stage: build
  script:
     - ./gradlew assembleDebug
  artifacts:
    paths:
      - app/build/outputs/apk/
      
unitTests:
  stage: test
  script:
    - ./gradlew test
```

### Bitbucket
*bitbucket-pipeline.yml*

```yml
image: hantrungkien/android-ci-sdk-ndk:latest

pipelines:
  default:
    - step:
        script:
          - export GRADLE_USER_HOME=`pwd`/.gradle
          - mkdir -p $GRADLE_USER_HOME
          - chmod +x ./gradlew
          - ./gradlew assembleDebug
```
