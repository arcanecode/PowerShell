# Workflows are similar to other commands
  workflow Invoke-Hello {"Hello"}
  Get-Command Invoke-Hello
  Get-Command Invoke-Hello -Syntax
  Get-Command Invoke-Hello | Format-List *

# Two ways to run - as a command or as a job
  Invoke-Hello

  $job = Invoke-Hello -AsJob


# Workflows are built on top of PowerShell Jobs. 
# They can be managed like any other jobs.
  Get-Job $job.Name

  # Can also use Stop-Job, Remove-Job, Receive-Job, Wait-Job
  # And new with workflows Suspend-Job and Resume-Job


# Workflows can run things in parallel ----------------------------------------

  workflow Invoke-ParallelWorkflow 
  {
    parallel {
               Get-Process -Name Power*

               "In parallel 1 of 5"
               "In parallel 2 of 5"
               "In parallel 3 of 5"
               "In parallel 4 of 5"
               "In parallel 5 of 5"

               Get-Service -Name WinRM
             }
   }

  # Run this several times. You will begin to see things execute
  # in what appears to be random sequences
  Invoke-ParallelWorkflow

# Sometimes within a parallel work you will still need to have ---------------
# some commands execute in a specific sequence. To do that, 
# use a sequence script block
  workflow Invoke-ParallelWorkflowWithSequence
  {
    parallel {
               Get-Process -Name Power*

               sequence
               {
                 "In sequence 1 of 5"
                 "In sequence 2 of 5"
                 "In sequence 3 of 5"
                 "In sequence 4 of 5"
                 "In sequence 5 of 5"
               }  

               "In parallel 1 of 5"
               "In parallel 2 of 5"
               "In parallel 3 of 5"
               "In parallel 4 of 5"
               "In parallel 5 of 5"

               Get-Service -Name WinRM
             }
   }

   # Run this several times. You'll note that while they execute
   # at the same time as the other commands (and hence the results
   # appear to be intertwined), they will always be executed in 
   # the exact sequence specified
   Clear-Host
   Invoke-ParallelWorkflowWithSequence


# With workflows you can iterate over a collection of items, 
# executing code against each object in paralell
  workflow Invoke-ForEachParallel
  {
    param([string[]]$ComputerNames)
    foreach -parallel($computer in $ComputerNames)
    {
      "Executing on $computer"
    }
  }

  # As with the other examples, run several times to see the effects
  Clear-Host
  $computers = (1..50)
  Invoke-ForEachParallel $computers


# With the latest release, workflows can call other workflows
  workflow Invoke-Inner
  { "Hi from inner workflow" }

  workflow Invoke-Outer
  {
    "Greetings from outer workflow"
    Invoke-Inner
  }

  Clear-Host
  Invoke-Outer

# Within a workflow you can define other workflows or functions
  workflow Invoke-NestedCommands
  {
    "Howdy from the main workflow!"

    # Here's the nested workflow
    workflow Invoke-NestedWorkflow
    { "    Here is the nested workflow" }

    # and here's the nested function
    function Invoke-NestedFunction
    { "    Here is the nested function" }

    "  Calling Nested Workflow..."
    Invoke-NestedWorkflow

    "  Calling Nested Function"
    Invoke-NestedFunction

    "All done!"
  }

  Clear-Host
  Invoke-NestedCommands

# Inline scripting 
# Provides a way to run code inside a workflow in isolation
# Also lets you run some commands not normally available 
# from a workflow

  workflow Invoke-InlineScript
  {
    # Note, the { must immediately follow the InlineScript command,
    # otherwise you'll get a syntax error
    InlineScript{
      $a = 2
      $b = $a + 2
      "Inside the script, the value of `$a is $a"
      "Inside the script, the value of `$b is $b"
    }

    # Note that variables are scoped to the script
    "Outside the script, the value of `$a is $a"
    "Outside the script, the value of `$b is $b"

  }

  Clear-Host
  Invoke-InlineScript


# Sometimes you need to get to a variable defined insided the workflow,
# from within the InlineScript. You can do that using the $using: syntax
  workflow Invoke-UsingScope
  {
    $a = 33
    "The inital value of `$a is $a"

    # Note, the { must immediately follow the InlineScript command,
    # otherwise you'll get a syntax error
    InlineScript{ "Inside the script, the PowerShell variable `$a is $a" }
    InlineScript{ "Inside the script, the Workflow variable `$a is $using:a" }

  }

  Clear-Host
  Invoke-UsingScope
  
  
  # Variables are tighly scoped, so name collisons are not an issue
  workflow Invoke-UsingScopeCreep
  {
    $a = 33
    "The inital value of `$a is $a"

    # Variable scope is limited to the script, thus you can 
    # use the same name inside a script without affecting the
    # same named variable outside
    InlineScript{ $a = 66; "Inside the first script, the PowerShell variable `$a is $a" }

    # To get to the outer variable, use the $using syntax
    InlineScript{ "Inside the second script, the Workflow variable `$a is $using:a" }

    "The final value of `$a is $a"

  }

  Clear-Host
  Invoke-UsingScopeCreep
  

# Scope doesn't just apply to inline script, it also applies to the parallel and sequence blocks
  
  workflow Invoke-WorkflowScope
  {
    $a = 33
    "The inital value of `$a is $a"

    parallel
    {
      sequence
      {
        # To alter a workflow defined variable inside
        # a parallel or sequence block, use the $workflow prefix
        $workflow:a = 42

        # Note that unlike inline scripts, you don't have to use the
        # $workflow prefix if all you are doing is reading the value
        "Inside the value of `$a is $a"
      }
    }
    
    "The final value of `$a is $a"
  }

  Clear-Host
  Invoke-WorkflowScope



# Setting workflow state
  workflow Set-WorkflowState
  {
    "Setting Workflow State..."

    # Calls the WWF persist activity
    Checkpoint-Workflow

    # Pretend like we're doing something useful
    "Yawn, I'm sleepy. Nap time."
    Start-Sleep -Seconds 10

    "OK I'm done."
  }

  Clear-Host
  Set-WorkflowState


# Suspending a job from inside that job
  workflow Invoke-DontWannaDoIt
  {
    Write-Warning -Message "Starting workflow Invoke-DontWannaDoIt"

    # Check to see if a file exists. If not suspend
    if((Test-Path 'C:\Users\Arcane\OneDrive\PS\Z2H\WFTest.csv') -eq $false)              #$sec -le 30)
    {
      Write-Warning -Message "Sorry bro, WFTest.csv not found! Use Resume-Job `$job.InstanceId to resume."
      Suspend-Workflow
    }

    # Job resumes at this point to do what it was supposed to 

  }
  
  # Delete it if it was left from a previous run
  Remove-Item 'C:\Users\Arcane\OneDrive\PS\Z2H\WFTest.csv' -ErrorAction SilentlyContinue

  # Invoke the job
  # Note normally we'd invoke with the -AsJob parameter, but if
  # we do then the warning messagers won't appear
  $job = Invoke-DontWannaDoIt #-AsJob

  # Just to show the Job ID  
  "`$job ID is $($job.Id)"

  # Get the status of the job using the id, note it shows SUSPENDED  
  Get-Job -id $job.Id 
  
  # Without doing anything, try to resume the job. Since the file still
  # doesn't exist, it will show as suspended
  Resume-Job $job.InstanceId # Can resume a job using it's ID or it's InstanceId
  Get-Job -id $job.Id 

  # Now export some data to create the file
  # Then resume the job
  Get-Process | Export-Csv 'C:\Users\Arcane\OneDrive\PS\Z2H\WFTest.csv'
  Resume-Job $job.InstanceId # Can resume a job using it's ID or it's InstanceId

  # Now get the status again, showing it's state as COMPLETED
  Get-Job $job.Id


# Getting and setting data about the workflow
  workflow Get-WorkflowData
  {
    $before = Get-PSWorkflowData[HashTable] -VariableToRetrieve All
    "The `$before.PSComputerName is $($before.PSComputerName)"
    
    Set-PSWorkflowData -PSComputerName "ArcaneCode"
    
    $after = Get-PSWorkflowData[string[]] -VariableToRetrieve PSComputerName
    "The after setting is $after"

  }

  Clear-Host
  Get-WorkflowData


