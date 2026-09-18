local Aim = {}

Aim.Name = "Aim"
Aim.Tab = "Combat"

Aim.Settings = {
    Enabled = false,
}

function Aim:Enable()

    self.Settings.Enabled = true

end

function Aim:Disable()

    self.Settings.Enabled = false

end

function Aim:Destroy()

    self:Disable()

end

return Aim
