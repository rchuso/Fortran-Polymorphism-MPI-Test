# Fortran-Polymorphism-MPI-Test
Test program for sending Polymorphic Fortran object over MPI - comparing OpenMPI and Mpich.

Sending Polymorphic Fortran over MPI
=============

This is a test code to demonstrate sending and receiving modern Fortran objects over MPI by referencing the Base Class in the MPI_SEND and the MPI_RECV methods.

Requirements
-------------

This was developed and runs on Linux Ubuntu 16.04 and Linux Mint 18 and 19.
I haven't tried it on other operating systems.
The fortran compiler used to develop this code was the gfortran-7, wrapped by the mpif90, which was provided by OpenMPI version 1.10 (or earlier).
I've also run this (a few years ago) with mpich - but I don't remember the version.

Building and Running
-------------

The supplied makefile compiles the single source file and puts the executable in a "bin" folder (not committed).

To execute the program:
  - mpiexec -n 2 /bin/PolymorphicFortran

The output should be similar to this:
    0:2      Has:[0:2 id:89 Datatype:73 Name:Fred]
    0:2     Sent:[0:2 id:89 Datatype:73 Name:Fred]
    0:2      Has:[id:59 Datatype:74 0:2 Name:Bam-bam Betty]
    0:2 Received:[id:71 Datatype:74 1:2 Name:Wilma Pebbles]
    1:2      Has:[1:2 id:59 Datatype:73 Name:Barney]
    1:2 Received:[0:2 id:89 Datatype:73 Name:Fred]
    1:2      Has:[id:71 Datatype:74 1:2 Name:Wilma Pebbles]
    1:2     Sent:[id:71 Datatype:74 1:2 Name:Wilma Pebbles]

or
    0:2      Has:[0:2 id:89 Datatype:73 Name:Fred]
    1:2      Has:[1:2 id:59 Datatype:73 Name:Barney]
    0:2     Sent:[0:2 id:89 Datatype:73 Name:Fred]
    0:2      Has:[id:59 Datatype:74 0:2 Name:Bam-bam Betty]
    1:2 Received:[0:2 id:89 Datatype:73 Name:Fred]
    1:2      Has:[id:71 Datatype:74 1:2 Name:Wilma Pebbles]
    1:2     Sent:[id:71 Datatype:74 1:2 Name:Wilma Pebbles]
    0:2 Received:[id:71 Datatype:74 1:2 Name:Wilma Pebbles]

The order and arrangement may be different - typical of threaded operations.
Even the output from one WRITE statement may be interspersed with that of another on the other node.
The first two numbers are the rank and size of the network. This test runs with 2 nodes only. So 0:2 identifies rank 0 of 2.
The second item in the print shows the state of the object prior to the object being sent or received (useful to see the state before use).

Application Structure
-------------

The source file contains a few modules and one test program.

Each module contains one TYPE - with its own Constructor and Destructor (FINAL) methods and whatever other methods it provides.
This is a standard I impose on myself, but not a requirement of the language.

The first module is _MpiAssist_ - to abstract some of the commonality of creating MPI message types.
MPI requires that you declare the types of non-standard messages sent between nodes - the standard ones are already provided ('MPI_INTEGER', 'MPI_CHARACTER', and so on.)
These additional messages must be defined to the MPI before they may be used - by invoking the 'MPI_TYPE_CREATE_STRUCT' and 'MPI_TYPE_COMMIT' MPI methods after defining
all the individual components of the message.
This first module provides methods to simplify the constructing of these messages.

The second module is the _MsgBase_ - the base class of all messages.
It is an abstract base class, and requires the implementing class create methods to get and register the MPI datatype to the system, and to display the object as a string.
This also provides a base item that's referenced in the MPI_SEND and MPI_RECV methods of MPI, and a place for storing the datatype when defined.

The OpenMPI send and receive methods take as a parameter the first item in the base class (which I've called "baseId").
The Mpich doesn't require referencing this first item, and works fine by referencing the object to be sent.
I suspect (or hope) one of these may eventually change so the two systems are equivalent.
I've never used other MPI implementations, so I can't say if they'd work or not.
Most of what I've used in the industry is Mpich on supercomputers and OpenMPI on desktops - YMMV.

The third module is _MsgCapabilities_ - to transport specifics about the current node back to rank 0 (the "control" node in my parlance.)
It implements the two abstract methods to create the datatype and register it to the MPI system, and another for simply showing the object as a string - useful only for debug purposes.
When the object is constructed, hostname, rank, and size are set.

The fourth module is _MsgOther_ - just to have a different derived class based on the _MsgBase_ class.
It provides other items for sending and receiving.

The program is the last thing in the file.
It creates messages of the _MsgCapabilities_ and _MsgOther_ types and a pointer to the _MsgBase_ type to send and receive.
Items in the different messages are initialized to show that they're different, and then the _sendReceive_ procedure in the _CONTAINS_ section of the main is called.
That procedure sends and receives the polymorphic objects and calls their "str" method to get their printable data for displaying to the screen.
Because the MPI is running on different cores, blades, or computers, the order of the print may be interspersed differently.

The MPI_SEND and MPI_RECV methods in the _sendReceive_ procedure in the main program reference the _baseId_ of the _MsgBase_ type, which works for OpenMPI.
To test this using the Mpich implementation, you may need to change the _objPtr%baseId_ to the simpler _objPtr_ instead.

Disclaimer
-------------

If you can find a better way to do this, please send a Pull Request.. I'm always ready to learn from the experts.
I'm just adding this here because I didn't find very much information on Polymorphism and Fortran in MPI environments when I searched - no workable examples.

