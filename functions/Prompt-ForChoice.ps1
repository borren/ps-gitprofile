
#instantiate with:
#$title = "Title"
#$info = "This info"
#$options = 1,2,3

#$input = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)

function PromptForChoice([string]$ParameterName, [ValidateNotNull()]$ChoiceNodes, [string]$prompt,
                                 [int[]]$defaults, [switch]$IsMultiChoice) 
                                 {
            $choices = New-Object 'System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]'
            $values = New-Object object[] $ChoiceNodes.Count
            $i = 0

            foreach ($choiceNode in $ChoiceNodes) {
                $label = InterpolateAttributeValue $choiceNode.label (GetErrorLocationParameterAttrVal $ParameterName label)
                $help  = InterpolateAttributeValue $choiceNode.help  (GetErrorLocationParameterAttrVal $ParameterName help)
                $value = InterpolateAttributeValue $choiceNode.value (GetErrorLocationParameterAttrVal $ParameterName value)

                $choice = New-Object System.Management.Automation.Host.ChoiceDescription -Arg $label,$help
                $choices.Add($choice)
                $values[$i++] = $value
            }

            $retval = [PSCustomObject]@{Values=@(); Indices=@()}

            if ($IsMultiChoice) {
                $selections = $Host.UI.PromptForChoice('', $prompt, $choices, $defaults)
                foreach ($selection in $selections) {
                    $retval.Values += $values[$selection]
                    $retval.Indices += $selection
                }
            }
            else {
                if ($defaults.Count -gt 1) {
                    throw ($LocalizedData.ParameterTypeChoiceMultipleDefault_F1 -f $ChoiceNodes.ParentNode.name)
                }

                $selection = $Host.UI.PromptForChoice('', $prompt, $choices, $defaults[0])
                $retval.Values = $values[$selection]
                $retval.Indices = $selection
            }

            $retval
        }
