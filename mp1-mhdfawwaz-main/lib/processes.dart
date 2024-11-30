import 'dart:ffi'; 
import 'dart:math';
import 'util/stats.dart'; // Importing utilities for statistical functions

/// Base class representing a general process that can generate events.
abstract class Process {
  // Name of the process
  final String name; 

  // Constructor to initialize the process name
  Process(this.name); 

  /// Abstract method to generate a list of events for this process.
  /// This method must be implemented by any class that extends `Process`.
  List<Event> generateEvents();
}

/// Class to represent an event in the system, with properties like arrival and duration.
class Event {
  final String processName;     // Name of the process that generates this event
  final int arrivalTime;        // The time at which the event arrives
  final int duration;           // Duration of the event
  int startTime = 0;            // The time when the event starts
  int waitTime = 0;             // The amount of time the event has to wait before starting 

  // Constructor to initialize the event with process name, arrival time, and duration.
  Event(this.processName, this.arrivalTime, this.duration);
}

/// Class for a singleton process, which generates exactly one event.
class SingletonProcess extends Process {
  final int duration;         // Duration of event
  final int arrival;          // Arrival time of event

  // Constructor to initialize name, duration, and arrival time for the event
  SingletonProcess(String name, this.duration, this.arrival) : super(name);

  @override
  List<Event> generateEvents() {
    // Create event and return it in a list
    return [Event(name, arrival, duration)];
  }
}

/// Class for a periodic process that generates multiple events at regular intervals.
class PeriodicProcess extends Process {
  final int duration;               // Duration of each event
  final int interarrivalTime;       // Time between the consecutive events
  final int firstArrival;           // Time of first event
  final int numRepetitions;         // Number of times the process repeats

  // Constructor to initialize all parameters for the periodic process
  PeriodicProcess(String name, this.duration, this.interarrivalTime, this.firstArrival, this.numRepetitions)
      : super(name);

  @override
  List<Event> generateEvents() {
    final events = <Event>[];          // List which holds the generated events
    for (int i = 0; i < numRepetitions; i++) {

      // arrival time for each event based on the first arrival and interarrival time
      final arrivalTime = firstArrival + i * interarrivalTime; 
      
      // add event to the list
      events.add(Event(name, arrivalTime, duration));
    }
    return events; // Return
  }
}

/// Class for a stochastic process, which generates events with random durations and interarrival times.
class StochasticProcess extends Process {
  final double meanDuration;              // Mean value for the event duration 
  final double meanInterarrivalTime;      // Mean value for the interarrival time between events
  final int firstArrival;                 // Time of the first event
  final int endTime;                      // No more events are generated after this

  // Constructor to initialize all parameters for the stochastic process
  StochasticProcess(String name, this.meanDuration, this.meanInterarrivalTime, this.firstArrival, this.endTime)
      : super(name);

  // Generates a list of events with stochastic arrival times and durations
  @override
  List<Event> generateEvents() {
    List<Event> events = []; // List to hold the generated events
    
   
    var expDuration = ExpDistribution(mean: meanDuration.toDouble());  // This is random duration generator
    var expInterarrival = ExpDistribution(mean: meanInterarrivalTime.toDouble());  // This is random interarrival time generator

    int arrivalTime = firstArrival;  // Starts with the first arrival time
    
    while (arrivalTime < endTime) {
      int duration = expDuration.next().toInt();
      
      // Creates a new event and add it to the list
      events.add(Event(name, arrivalTime, duration)); 
      
      // Update the arrival time for the next event by adding a random interarrival time
      arrivalTime += expInterarrival.next().toInt();
    }
    
    return events; // Return the list of events that are generated
  }
}
