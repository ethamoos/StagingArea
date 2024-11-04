# StagingArea
 This is a Jamf based app for managing Pre-Stages. 
 
 * View, add and edit pre-stage allocations from a single interfance.


**About Staging Area**

Under Automated Device Enrollment (or DEP as many of us still prefer to call it) the Jamf pre-stage into which a device is added is the key element that determines how the machine will be built.
This initial setting defines the build path for the device and can be set that can have many different outcomes. This is particularly true in  a large organisation with many different types of users requiring different software and basic configuration.

For example a school with:

* Students
* Teachers
* Admin staff
* IT staff
* Open Access devices
* Loan devices

The prestage that a device is assigned to can therefore determine if a machine is going to be built as a: 

* A student laptop 
* A academic staff laptop
* An admin users machine
* A Creative open access machine
* A Stripped down research machine with minimal management
* Or any other variation that you might choose.

In this sense, managing the prestage your devices belong to is really important and something that you want to be able to keep track of, easily. Inspite of this, in Jamf it is actually not an easy task.

To view what prestage a device is assigned to requires the following steps

**Select Automated Device Enrollment in Global Management**
![global management 2](https://github.com/user-attachments/assets/1eba8850-0617-4bd1-bead-16cf5f8e7db9)


**Select Devices within Automated Device Enrollment**

![ABM](https://github.com/user-attachments/assets/e221ce85-f783-496c-a3af-c4afa005fc1f)
**Select Apple School Manager or Apple Business Manager within Automated Device Enrollment**

![select ABM](https://github.com/user-attachments/assets/b2c7a80b-c88f-4785-ae8d-c2e90ecde876)


**Select an actual device and view/edit its current pre-stage assignment status**

![filter device edit](https://github.com/user-attachments/assets/ec68a133-401e-4d6b-a195-e7045cfc0c22)

**Moving Devices Between Prestages**

Ideally, once a device is added to a pre-stage that is where it will stay, but in reality devices often move between pre-stages and there are various scenarios that require that.

* Moving from a test to a live pre-stage
* A device has been assigned to the wrong prestage and needs to be rebuilt. 
* A device is within Jamf, but not in a prestage at all. 

As we can see, managing this is something which is currently quite clunky within the JSS and requires a lot of navigation.


**StagingArea** is a simple tool which will make this easier. Currently, it will do the following:

* List all prestages available in Jamf - each prestage can be clicked on to get full details

* List all devices in a jamf instance enrolled in a pre-stage
* Each device can then be moved to a different prestage
* Select a prestage by id, list all devices in that pre-stage and be able to add/remove a device to it.
* Select a device by ID and then change its assigned prestage
* Enter a device not currently assigned to a prestage and add it to one
* Remove a device from a prestage
