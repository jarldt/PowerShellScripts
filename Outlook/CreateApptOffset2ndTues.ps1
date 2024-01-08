<#
===========================================================================

CreateApptOffset2ndTues.ps1
Copyright (C) 2024 Joshua Arldt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

===========================================================================
#>

# Define the appointment parameters
$apptSubject = "Meeting with John"
$apptDuration = 60 # in minutes
$apptRecurrence = 12 # in months
$daysToAdd = 0 # number of days to add to the 2nd Tuesday date

# Set the scheduling date as the offset of the 2nd Tuesday of the month
$currMonth = Get-Date -Format "MM"
$secondTuesday = Get-Date "01/$currMonth/$(Get-Date -Year (Get-Date).Year -Month $currMonth -Day 1).AddDays(7 * 1).DayOfWeek.Value" -UFormat "%m/%d/%Y"
$schedulingDate = $secondTuesday.AddDays($daysToAdd)

# Loop through each month and create an appointment
for ($i=0; $i -lt $apptRecurrence; $i++) {
    # Calculate the date of the appointment
    $apptDate = $schedulingDate.AddDays(7 * $i) # add the number of weeks offset
    
    $apptStartTime = $apptDate.AddHours(10) # set the start time to 10:00 AM
    $apptEndTime = $apptStartTime.AddMinutes($apptDuration) # set the end time based on the duration
    
    # Create the appointment
    $outlook = New-Object -ComObject Outlook.Application
    $newAppt = $outlook.CreateItem(1)
    $newAppt.Subject = $apptSubject
    $newAppt.Start = $apptStartTime
    $newAppt.End = $apptEndTime
    $newAppt.ReminderSet = $true
    $newAppt.ReminderMinutesBeforeStart = 15 # set a reminder 15 minutes before the appointment
    $newAppt.Save()
}

Write-Host "Appointments created for the next $apptRecurrence months starting from $schedulingDate with an offset of $daysToAdd days"

