<#
===========================================================================

CreateApptOffset2ndTuesGUI.ps1
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

# Define the initial appointment parameters
<#$apptSubject = ""
$apptStartTime = ""
$apptEndTime = ""
$apptRecurrence = ""
$daysToAdd = ""#>

# Create a GUI to prompt for appointment parameters
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Width = 400
$form.Height = 300
$form.Text = "Set Appointment Parameters"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedSingle'

$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "Appointment Subject:"
$label1.AutoSize = $true
$label1.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($label1)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(20, 40)
$textBox1.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($textBox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Appointment Start Time:"
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(20, 70)
$form.Controls.Add($label2)

$dateTimePicker1 = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker1.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
$dateTimePicker1.CustomFormat = "MM/dd/yyyy hh:mm tt"
$dateTimePicker1.ShowUpDown = $true
$dateTimePicker1.Location = New-Object System.Drawing.Point(20, 90)
$dateTimePicker1.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($dateTimePicker1)

$label3 = New-Object System.Windows.Forms.Label
$label3.Text = "Appointment End Time:"
$label3.AutoSize = $true
$label3.Location = New-Object System.Drawing.Point(20, 120)
$form.Controls.Add($label3)

$dateTimePicker2 = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker2.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
$dateTimePicker2.CustomFormat = "MM/dd/yyyy hh:mm tt"
$dateTimePicker2.ShowUpDown = $true
$dateTimePicker2.Location = New-Object System.Drawing.Point(20, 140)
$dateTimePicker2.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($dateTimePicker2)

$label4 = New-Object System.Windows.Forms.Label
$label4.Text = "Appointment Recurrence (in months):"
$label4.AutoSize = $true
$label4.Location = New-Object System.Drawing.Point(20, 170)
$form.Controls.Add($label4)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(20, 190)
$textBox3.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($textBox3)

$label5 = New-Object System.Windows.Forms.Label
$label5.Text = "Number of Days to Add to the 2nd Tuesday:"
$label5.AutoSize = $true
$label5.Location = New-Object System.Drawing.Point(20, 220)
$form.Controls.Add($label5)

$textBox4 = New-Object System.Windows.Forms.TextBox
$textBox4.Location = New-Object System.Drawing.Point(20, 240)
$textBox4.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($textBox4)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(145, 150)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)

# Define the cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(145, 120)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.Add($cancelButton)

# Add an event handler for the cancel button
$cancelButton.Add_Click({
    $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Close()
})

# Show the form
$form.ShowDialog() | Out-Null

<#if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    # Set the appointment parameters based on user input
    $apptSubject = $textBox1.Text
    $start = $textBox2.Text
    $end = $textBox3.Text
    $apptRecurrence = $textBox4.Text

    # Convert the appointment duration to a TimeSpan object
    $duration = [TimeSpan]::FromMinutes($end-$start)

    # Get the Outlook application object
    $outlook = New-Object -ComObject Outlook.Application

    # Create a new appointment item
    $appointment = $outlook.CreateItem(1)

    # Set the subject, start time, end time, and duration of the appointment
    $appointment.Subject = $apptSubject
    $appointment.Start = $start
    $appointment.End = $end
    $appointment.Duration = $duration.TotalMinutes

    # Set the recurrence pattern if recurrence is selected
    if ($apptRecurrence) {
        $recurrence = $appointment.GetRecurrencePattern()
        $recurrence.PatternStartDate = $startTime
        $recurrence.PatternEndDate = $endTime
        $recurrence.Interval = $apptRecurrence
        $recurrence.DayOfWeekMask = "0010000" # Every 2nd Tuesday
        $recurrence.RecurrenceType = 1 # Weekly recurrence
        $recurrence.Occurrences = $daysToAdd / 7 # Number of occurrences based on the number of days to add
        $recurrence.RangeType = 0 # End after a certain number of occurrences
        $appointment.Save()
    }
    else {
        $appointment.Save()
    }

    # Display a confirmation message to the user
    [System.Windows.Forms.MessageBox]::Show("Appointment saved to Outlook.")
}
else {
    # Display a message to the user indicating that the appointment creation was cancelled
    [System.Windows.Forms.MessageBox]::Show("Appointment creation cancelled.")
}#>
