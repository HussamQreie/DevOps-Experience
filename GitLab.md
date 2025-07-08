# gitlab
```sh
stages:
  - build # stage 1
  - test # stage 2


build-car: # job name- creates a container by default 
  image: alpine # container image
  stage: build # this job is a part of build stage
  script:  # open the container and apply these shell commands
   - echo "Building the car!"
   - mkdir build
   - cd build
   - touch car.txt 
   - echo "KIA SPORTAGE 1996" > car.txt
   - echo "Overwritten Text" >> car.txt
   - cat car.txt

  artifacts: # save/store a directory's content for other stages diff containers but gitlab runner will download this in next containers with stage s
   paths:
    - build/

test-car:
  image: alpine
  stage: test
  script: 
   - test -f build/car.txt
   - grep "KIA" build/car.txt
   - grep "Overwritten Text" build/car.txt
```
