local CollectionService = game:GetService("CollectionService")

-- UBAH KOORDINAT DI BAWAH INI
local TARGET_DESTINATION = Vector3.new(547.809, 7.516, 1921.578)
local TARGET_RETURN = Vector3.new(14.809, 7.516, 146) -- Ganti dengan koordinat pintu masuk aslimu

local GATE_GO = "TeleportGate"
local GATE_BACK = "TeleportGateBack"

local playerDebounce = {}
local function setupTeleporter(sensor, isGoingBack)
    -- Pastikan ini adalah part
    if not sensor:IsA("BasePart") then return end
    
    sensor.Touched:Connect(function(hit)
        local character = hit and hit.Parent
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoid and rootPart and humanoid.Health > 0 then
            -- Cek apakah player ini sedang dalam cooldown teleport
            local lastTeleport = playerDebounce[character]
            if lastTeleport and (os.clock() - lastTeleport) < 3 then
                return -- Keluar jika belum 3 detik sejak teleport terakhir
            end
            
            -- Masukkan player ke daftar cooldown
            playerDebounce[character] = os.clock()
            
            -- Tentukan lokasi target berdasarkan apakah ini pintu pergi atau pintu pulang
            local targetLocation = sensor:GetAttribute("TargetLocation")
            if not targetLocation then
                targetLocation = isGoingBack and TARGET_RETURN or TARGET_DESTINATION
            end
            
            -- Parsing target menjadi CFrame apabila ia bukan CFrame (cth: Vector3)
            local pivotCFrame = typeof(targetLocation) == "CFrame" and targetLocation or CFrame.new(targetLocation)
            
            -- Menggunakan PivotTo sangat aman buat karaker agar tidak nge-glitch/nyangkut
            character:PivotTo(pivotCFrame)
        end
    end)
end

-- Menghubungkan fungsi ke part baru yang diberi Tag atau Nama
local function checkAndSetup(block)
    if block.Name == GATE_GO or CollectionService:HasTag(block, GATE_GO) then
        setupTeleporter(block, false)
    elseif block.Name == GATE_BACK or CollectionService:HasTag(block, GATE_BACK) then
        setupTeleporter(block, true)
    end
end

-- Saat game mulai, cek semua part di dalam Workspace
for _, block in ipairs(workspace:GetDescendants()) do
    if block:IsA("BasePart") then
        checkAndSetup(block)
    end
end

-- Deteksi jika ada part di dalam Workspace yang dibuat saat game sedang berjalan
workspace.DescendantAdded:Connect(function(block)
    if block:IsA("BasePart") then
        checkAndSetup(block)
    end
end)