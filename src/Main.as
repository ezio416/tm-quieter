// c 2025-05-19
// m 2025-07-11

Json::Value@  choices     = Json::Object();
const string  choicesFile = IO::FromStorageFolder("choices.json");
const string  pluginColor = "\\$FAA";
const string  pluginIcon  = Icons::Kenney::SoundOff;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
Sound@[]      sounds;

void Main() {
    LoadChoices();

    auto App = cast<CTrackMania>(GetApp());
    string lastLoadedTitle;

#if TURBO
    LoadSounds();
    SetChoices();
#endif

    while (true) {
        yield();

        if (true
#if TMNEXT || MP4
            and App.LoadedManiaTitle !is null
            and App.LoadedManiaTitle.BaseTitleId != lastLoadedTitle
#elif TURBO
            and App.Challenge !is null
            and App.Challenge.CollectionName != lastLoadedTitle
#endif
        ) {
#if TMNEXT || MP4
            lastLoadedTitle = App.LoadedManiaTitle.BaseTitleId;
#elif TURBO
            lastLoadedTitle = App.Challenge.CollectionName;
#endif
            trace("new title: " + lastLoadedTitle);

            LoadSounds();
            SetChoices();
        }
    }
}

void OnSettingsSave(Settings::Section&) {
    SaveChoices();
}

void AddSoundsFromFolder(const string&in folderName, const string&in sourceName) {
    CSystemFidsFolder@ Folder = Fids::GetGameFolder("GameData/" + folderName);
    if (Folder is null) {
        warn("null fid folder: " + folderName + " (" + sourceName + ")");
        return;
    }

    uint count = 0;

    for (uint i = 0; i < Folder.Leaves.Length; i++) {
        auto File = cast<CSystemFidFile>(Folder.Leaves[i]);
        if (File !is null) {
            auto PlugSound = cast<CPlugSound>(File.Nod);
            if (PlugSound !is null) {
                auto sound = Sound(PlugSound, sourceName);
                if (true
                    and sound.name.Length > 0
                    and sound.name != "empty"
                ) {
                    sounds.InsertLast(sound);
                    count++;
                }
            }
        }
    }

    if (count > 0) {
        trace("found " + count + " sounds in " + folderName + " (" + sourceName + ")");
    }
}

void LoadChoices() {
    if (IO::FileExists(choicesFile)) {
        trace("loading choices");

        try {
            @choices = Json::FromFile(choicesFile);
        } catch {
            @choices = Json::Object();
        }

        if (choices.GetType() != Json::Type::Object) {
            warn("choices isn't an object!");
            @choices = Json::Object();
        }
    }
}

void LoadSounds() {
    const uint64 start = Time::Now;
    sounds = {};

    AddSoundsFromFolder("Menu/Media/audio/Sound",                                   "Menu");
#if TMNEXT || MP4
    AddSoundsFromFolder("Vehicles/Media/Audio/Sound",                               "Vehicles");
#endif
#if TMNEXT
    AddSoundsFromFolder("Vehicles/Cars/CarDesert/Audio",                            "CarDesert");
    AddSoundsFromFolder("Vehicles/Cars/CarRally/Audio",                             "CarRally");
    AddSoundsFromFolder("Vehicles/Cars/CarSnow/Audio",                              "CarSnow");
    AddSoundsFromFolder("Vehicles/Cars/CarSport/Audio",                             "CarSport");
    AddSoundsFromFolder("Vehicles/Cars/CommonMedia/Audio",                          "Common");
    AddSoundsFromFolder("Vehicles/Media/Audio/Sound/Water",                         "Water");
#elif MP4
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Weapon/Arrow",                "Arrow");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Asphalt",  "Asphalt");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Man/Body",          "Body");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Impact/Body",                 "Body2");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Misc/Bonus",                  "Bonus");
    AddSoundsFromFolder("Media/Manialinks/Nadeo/Common/ChannelProgression",         "ChannelProgression");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Dirt",     "Dirt");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Impact/Dirt",                 "Dirt2");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/Gauge",                    "Gauge");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Grass",    "Grass");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Impact/Grass",                "Grass2");
    AddSoundsFromFolder("Media/Manialinks/Nadeo/TrackMania/Ingame/Sound",           "Ingame");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Man/Injured",       "Injured");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Weapon/Laser",                "Laser");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Man",               "Man");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Metal",    "Metal");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Impact/Metal",                "Metal2");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Misc",                        "Misc");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Weapon/Nucleus",              "Nucleus");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Pavement", "Pavement");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Misc/Pole",                   "Pole");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/Record",                   "Record");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Weapon/Rocket",               "Rocket");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/RoundEvent",               "RoundEvent");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Weapon/ShortRange",           "ShortRange");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Snow",     "Snow");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound",                             "Sound");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/SoundBreak",               "SoundBreak");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/SoundCounter",             "SoundCounter");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/SoundStartEndMatch",       "SoundStartEndMatch");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Stone",    "Stone");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Tech",     "Tech");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/Time",                     "Time");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI/TimeAttack",               "TimeAttack");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Trunk",    "Trunk");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/UI",                          "UI");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Water",    "Water");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Impact/Water",                "Water2");
    AddSoundsFromFolder("Menu/Media/audio/Sound/Wav",                               "Wav");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Weapon",                      "Weapon");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Character/Material/Wood",     "Wood");
    AddSoundsFromFolder("ShootMania/Media/Audio/Sound/Impact/Wood",                 "Wood2");
#elif TURBO
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Vehicles/Agp/Canyon",         "Canyon");
    AddSoundsFromFolder("CanyonCE/Media/Audio/Sound/Wav",                           "CanyonWav");
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Wav",                         "CommonWav");
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Vehicles/Wav",                "CommonWav2");
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Vehicles/Agp/Lagoon",         "Lagoon");
    AddSoundsFromFolder("LagoonCE/Media/Audio/Sound",                               "LagoonSound");
    AddSoundsFromFolder("Menu/Media/audio/Sound/Wav",                               "MenuWav");
    AddSoundsFromFolder("ValleyCE/Media/Audio/Sound",                               "ValleySound");
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Vehicles/Agp/Stadium",        "Stadium");
    AddSoundsFromFolder("StadiumCE/Media/Audio/Sound/Wav",                          "StadiumWav");
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Vehicles/WavData/ValleyMisc", "ValleyMisc");
    AddSoundsFromFolder("CommonTMCE/Media/Audio/Sound/Vehicles/WavData",            "WavData");
#endif

    sounds.SortAsc();
    trace("found " + sounds.Length + " sounds after " + (Time::Now - start) + "ms");
}

void SaveChoices() {
    trace("saving choices");

    try {
        Json::ToFile(choicesFile, choices, true);
    } catch {
        error("error saving choices: " + getExceptionInfo());
    }
}

void SetChoices() {
    trace("setting choices");

    for (uint i = 0; i < sounds.Length; i++) {
        if (choices.HasKey(sounds[i].uid)) {
            Json::Value@ choice = choices[sounds[i].uid];
            if (choice.GetType() == Json::Type::Number) {
                sounds[i].volume = float(choice);
            }
        }
    }
}

[SettingsTab name="Sounds" icon="Kenney::SoundOn" order=0]
void RenderSounds() {
    if (UI::BeginTable("##table-sliders", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("folder", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("mute", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("restore", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("slider", UI::TableColumnFlags::WidthStretch);
        UI::TableHeadersRow();

        UI::ListClipper clipper(sounds.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Sound@ sound = sounds[i];

                UI::BeginDisabled(sound.sound is null);

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::AlignTextToFramePadding();
                UI::Text(sound.name);

                UI::TableNextColumn();
                UI::AlignTextToFramePadding();
                UI::Text("\\$666" + sound.folder);

                UI::TableNextColumn();
                UI::BeginDisabled(sound.muted);
                if (UI::Button("mute##" + i)) {
                    sound.Mute();
                }
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::BeginDisabled(sound.restored);
                if (UI::Button("restore##" + i)) {
                    sound.Restore();
                }
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::SetNextItemWidth(UI::GetContentRegionAvail().x / UI::GetScale());
                const float volume = UI::SliderFloat("##slider" + i, sound.volume, -60.0f, 20.0f);
                if (sound.volume != volume) {
                    sound.volume = volume;
                }

                UI::EndDisabled();
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }
}

[SettingsTab name="Debug" icon="Bug" order=1]
void RenderDebug() {
    UI::SeparatorText("App.AudioPort.Sources");

    CAudioPort@ AudioPort = GetApp().AudioPort;
    for (uint i = 0; i < AudioPort.Sources.Length; i++) {
        CAudioSource@ Source = AudioPort.Sources[i];
        if (Source !is null and Source.PlugSound !is null) {
            auto sound = Sound(Source.PlugSound, "AudioPort");
            if (sound.name.Length > 0 and sound.name != "empty") {
                UI::Selectable(tostring(i) + " " + sound.name, Source.IsPlaying);
            }
        }
    }
}
