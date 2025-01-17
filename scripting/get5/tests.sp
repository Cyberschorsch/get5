Action Command_Test(int args) {
  Get5_Test();
  return Plugin_Handled;
}

static void Get5_Test() {
  if (g_GameState != Get5State_None) {
    LogMessage("Cannot run Get5 tests while a match is loaded.");
    return;
  }

  char mapName[255];
  GetCleanMapName(mapName, sizeof(mapName));
  if (!StrEqual(mapName, "de_dust2")) {
    LogMessage("Tests should be run with de_dust2 loaded only. Please change the map and run the command again.");
    return;
  }

  // We reset these to default as tests need them to be consistent.
  SetConVarStringSafe("mp_teamscore_max", "0");
  SetConVarStringSafe("mp_teammatchstat_txt", "");
  SetConVarStringSafe("mp_teamprediction_pct", "0");

  SetConVarStringSafe("mp_teamname_1", "");
  SetConVarStringSafe("mp_teamflag_1", "");
  SetConVarStringSafe("mp_teamlogo_1", "");
  SetConVarStringSafe("mp_teammatchstat_1", "");
  SetConVarStringSafe("mp_teamscore_1", "");

  SetConVarStringSafe("mp_teamname_2", "");
  SetConVarStringSafe("mp_teamflag_2", "");
  SetConVarStringSafe("mp_teamlogo_2", "");
  SetConVarStringSafe("mp_teammatchstat_2", "");
  SetConVarStringSafe("mp_teamscore_2", "");

  ValidMatchConfigTest("addons/sourcemod/configs/get5/tests/default_valid.json");
  ValidMatchConfigTest("addons/sourcemod/configs/get5/tests/default_valid.cfg");

  MatchConfigNotFoundTest();

  InvalidMatchConfigFile("addons/sourcemod/configs/get5/tests/invalid_config.json");
  InvalidMatchConfigFile("addons/sourcemod/configs/get5/tests/invalid_config.cfg");

  MapListFromFileTest();
  LoadTeamFromFileTest();
  Team1StartTTest();
  MissingPropertiesTest();

  Utils_Test();
  LogMessage("Tests complete!");
}

static void MissingPropertiesTest() {
  SetTestContext("MissingPropertiesTest");

  char error[PLATFORM_MAX_PATH];
  AssertFalse("Load missing team1 JSON", LoadMatchConfig("addons/sourcemod/configs/get5/tests/missing_team1.json", error));
  AssertStrEq("Load missing team1 JSON error", error, "Missing \"team1\" section in match config JSON.");

  AssertFalse("Load missing team2 JSON", LoadMatchConfig("addons/sourcemod/configs/get5/tests/missing_team2.json", error));
  AssertStrEq("Load missing team2 JSON error", error, "Missing \"team2\" section in match config JSON.");

  AssertFalse("Load missing maplist JSON", LoadMatchConfig("addons/sourcemod/configs/get5/tests/missing_maplist.json", error));
  AssertStrEq("Load missing maplist JSON error", error, "Missing \"maplist\" section in match config JSON.");

  AssertFalse("Load missing team1 KV", LoadMatchConfig("addons/sourcemod/configs/get5/tests/missing_team1.cfg", error));
  AssertStrEq("Load missing team1 KV error", error, "Missing \"team1\" section in match config KeyValues.");

  AssertFalse("Load missing team2 KV", LoadMatchConfig("addons/sourcemod/configs/get5/tests/missing_team2.cfg", error));
  AssertStrEq("Load missing team2 KV error", error, "Missing \"team2\" section in match config KeyValues.");

  AssertFalse("Load missing maplist KV", LoadMatchConfig("addons/sourcemod/configs/get5/tests/missing_maplist.cfg", error));
  AssertStrEq("Load missing maplist KV error", error, "Missing \"maplist\" section in match config KeyValues.");
}

static void MatchConfigNotFoundTest() {
  SetTestContext("MatchConfigNotFoundTest");
  char error[PLATFORM_MAX_PATH];
  AssertFalse("Load match config does not exist", LoadMatchConfig("addons/sourcemod/configs/get5/tests/file_not_found.cfg", error));
  AssertTrue("Match config does not exist error", StrContains(error, "Match config file doesn't exist") != -1);
}

static void MapListFromFileTest() {
  SetTestContext("MapListFromFileTest");
  char error[PLATFORM_MAX_PATH];

  // JSON
  MapListValid("addons/sourcemod/configs/get5/tests/fromfile_maplist_valid.json");

  AssertFalse("Load empty maplist config JSON", LoadMatchConfig("addons/sourcemod/configs/get5/tests/fromfile_maplist_empty.json", error));
  AssertStrEq("Load empty maplist config JSON", error, "\"maplist\" is empty array.");

  AssertFalse("Load maplist fromfile file not found config", LoadMatchConfig("addons/sourcemod/configs/get5/tests/fromfile_maplist_not_found.json", error));
  AssertEq("Load maplist fromfile file not found config", StrContains(error, "Maplist fromfile file does not exist"), 0);

  AssertFalse("Load maplist fromfile config not array JSON", LoadMatchConfig("addons/sourcemod/configs/get5/tests/fromfile_maplist_not_array.json", error));
  AssertStrEq("Load maplist fromfile config not array JSON", error, "\"maplist\" object in match configuration file must have a non-empty \"fromfile\" property or be an array.");

  AssertFalse("Load maplist fromfile config empty string JSON", LoadMatchConfig("addons/sourcemod/configs/get5/tests/fromfile_maplist_empty_string.json", error));
  AssertStrEq("Load maplist fromfile config empty string JSON", error, "\"maplist\" object in match configuration file must have a non-empty \"fromfile\" property or be an array.");

  // KeyValues
  MapListValid("addons/sourcemod/configs/get5/tests/fromfile_maplist_valid.cfg");

  AssertFalse("Load maplist fromfile config invalid KV", LoadMatchConfig("addons/sourcemod/configs/get5/tests/fromfile_maplist_invalid.cfg", error));
  AssertStrEq("Load maplist fromfile config invalid KV", error, "\"maplist\" has no valid subkeys in match config KV file.");

}

static void InvalidMatchConfigFile(const char[] matchConfig) {
  SetTestContext("InvalidMatchConfigFile");
  char error[PLATFORM_MAX_PATH];
  AssertFalse("Load invalid match config file", LoadMatchConfig(matchConfig, error));
  AssertTrue("Invalid config file error", StrContains(error, "Failed to read match config from file") != -1);
}

static void MapListValid(const char[] file) {
  char mapName[32];
  char err[32];
  AssertTrue("Load valid fromfile maplist config", LoadMatchConfig(file, err));
  AssertEq("Map List Length", g_MapPoolList.Length, 3);
  g_MapPoolList.GetString(0, mapName, sizeof(mapName));
  AssertStrEq("Map 1 Fromfile Name", mapName, "de_ancient");
  g_MapPoolList.GetString(1, mapName, sizeof(mapName));
  AssertStrEq("Map 2 Fromfile Name", mapName, "de_overpass");
  g_MapPoolList.GetString(2, mapName, sizeof(mapName));
  AssertStrEq("Map 3 Fromfile Name", mapName, "de_inferno");
  EndSeries(Get5Team_None, false, 0.0);
}

static void Team1StartTTest() {
  SetTestContext("Team1StartTTest");
  char err[255];
  AssertTrue("load config", LoadMatchConfig("addons/sourcemod/configs/get5/tests/default_valid_team1t.json", err));

  // We test that the mp_ cvars are correctly inverted when team 1 starts T.
  // Series score 1 in the loaded config puts them on the second map, where they start T.
  AssertConVarEquals("mp_teamname_2", "Team A Start T [NOT READY]");
  AssertConVarEquals("mp_teamflag_2", "NO");
  AssertConVarEquals("mp_teamlogo_2", "start_t_logo");
  AssertConVarEquals("mp_teammatchstat_2", "GG T WIN");
  AssertConVarEquals("mp_teamscore_2", "1");

  EndSeries(Get5Team_None, false, 0.0);
}

static void LoadTeamFromFileTest() {
  SetTestContext("LoadTeamFromFileTest");
  char err[255];
  AssertTrue("load config", LoadMatchConfig("addons/sourcemod/configs/get5/tests/default_valid.json", err));
  AssertTrue("load team", LoadTeamDataFromFile("addons/sourcemod/configs/get5/tests/team2_array.json", Get5Team_2, err));

  char playerId[32];
  char playerName[32];
  ArrayList playersTeam2 = GetTeamPlayers(Get5Team_2);
  AssertEq("Team B Player Length", playersTeam2.Length, 4);

  playersTeam2.GetString(0, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 1 Team B", playerId, "76561198065028911");
  AssertStrEq("Name Player 1 Team B", playerName, "");

  playersTeam2.GetString(1, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 2 Team B", playerId, "76561198065027917");
  AssertStrEq("Name Player 2 Team B", playerName, "");

  playersTeam2.GetString(2, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 3 Team B", playerId, "76561198065028119");
  AssertStrEq("Name Player 3 Team B", playerName, "");

  AssertStrEq("Team B Name", g_TeamNames[Get5Team_2], "Team B Array");
  AssertStrEq("Team B Logo", g_TeamLogos[Get5Team_2], "fromfile_team_array");
  AssertStrEq("Team B Flag", g_TeamFlags[Get5Team_2], "SE");
  AssertStrEq("Team B Tag", g_TeamTags[Get5Team_2], "TAG-FA");
  AssertStrEq("Team B MatchText", g_TeamMatchTexts[Get5Team_2], "");

  AssertFalse("load team file not found", LoadTeamDataFromFile("addons/sourcemod/configs/get5/tests/file_not_found.json", Get5Team_2, err));
  AssertEq("load team file not found", StrContains(err, "Team fromfile file does not exist"), 0);

  AssertFalse("JSON load team file invalid", LoadTeamDataFromFile("addons/sourcemod/configs/get5/tests/invalid_config.json", Get5Team_2, err));
  AssertEq("JSON load team file invalid", StrContains(err, "Cannot read team config from JSON file"), 0);

  AssertFalse("KV load team file invalid", LoadTeamDataFromFile("addons/sourcemod/configs/get5/tests/invalid_config.cfg", Get5Team_2, err));
  AssertEq("KV load team file invalid", StrContains(err, "Cannot read team config from KV file"), 0);

  EndSeries(Get5Team_None, false, 0.0);
}

static void ValidMatchConfigTest(const char[] matchConfig) {
  SetTestContext("ValidMatchConfigTest");
  char error[PLATFORM_MAX_PATH];
  AssertTrue("Load match config", LoadMatchConfig(matchConfig, error));

  char playerId[32];
  char playerName[32];
  ArrayList playersTeam1 = GetTeamPlayers(Get5Team_1);
  AssertEq("Team A Player Length", playersTeam1.Length, 5);

  playersTeam1.GetString(0, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 1 Team A", playerId, "76561197996413459");
  AssertStrEq("Name Player 1 Team A", playerName, "PlayerAName1");

  playersTeam1.GetString(1, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 2 Team A", playerId, "76561197996426756");
  AssertStrEq("Name Player 2 Team A", playerName, "PlayerAName2");

  playersTeam1.GetString(2, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 2 Team A", playerId, "76561197996426757");
  AssertStrEq("Name Player 3 Team A", playerName, "PlayerAName3");

  playersTeam1.GetString(3, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 2 Team A", playerId, "76561197996426758");
  AssertStrEq("Name Player 4 Team A", playerName, "PlayerAName4");

  playersTeam1.GetString(4, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 2 Team A", playerId, "76561197996426759");
  AssertStrEq("Name Player 5 Team A", playerName, "PlayerAName5");

  ArrayList coachesTeam1 = GetTeamCoaches(Get5Team_1);
  AssertEq("Team A Coaches Length", coachesTeam1.Length, 2);
  coachesTeam1.GetString(0, playerId, sizeof(playerId));

  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Coach 1 Team A", playerId, "76561197996426735");
  AssertStrEq("Name Coach 1 Team A", playerName, "CoachAName1");

  coachesTeam1.GetString(1, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Coach 2 Team A", playerId, "76561197946789735");
  AssertStrEq("Name Coach 2 Team A", playerName, "CoachAName2");

  AssertStrEq("Team A Name", g_TeamNames[Get5Team_1], "Team A Default");
  AssertStrEq("Team A Logo", g_TeamLogos[Get5Team_1], "logofilename");
  AssertStrEq("Team A Flag", g_TeamFlags[Get5Team_1], "US");
  AssertStrEq("Team A Tag", g_TeamTags[Get5Team_1], "TAG-A");
  AssertStrEq("Team A MatchText", g_TeamMatchTexts[Get5Team_1], "Defending Champions");

  ArrayList playersTeam2 = GetTeamPlayers(Get5Team_2);
  AssertEq("Team B Player Length", playersTeam2.Length, 3);

  playersTeam2.GetString(0, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 1 Team B", playerId, "76561198064968911");
  AssertStrEq("Name Player 1 Team B", playerName, "PlayerBName1");

  playersTeam2.GetString(1, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 2 Team B", playerId, "76561198064967917");
  AssertStrEq("Name Player 2 Team B", playerName, "PlayerBName2");

  playersTeam2.GetString(2, playerId, sizeof(playerId));
  g_PlayerNames.GetString(playerId, playerName, sizeof(playerName));
  AssertStrEq("Steam ID Player 3 Team B", playerId, "76561198064968119");
  AssertStrEq("Name Player 3 Team B", playerName, "PlayerBName3");

  AssertEq("Team B Coaches Empty", GetTeamCoaches(Get5Team_2).Length, 0);

  AssertStrEq("Team B Name", g_TeamNames[Get5Team_2], "Team B Default");
  AssertStrEq("Team B Logo", g_TeamLogos[Get5Team_2], "fromfile_team");
  AssertStrEq("Team B Flag", g_TeamFlags[Get5Team_2], "DE");
  AssertStrEq("Team B Tag", g_TeamTags[Get5Team_2], "TAG-FF");
  AssertStrEq("Team B MatchText", g_TeamMatchTexts[Get5Team_2], "");

  GetTeamPlayers(Get5Team_Spec).GetString(0, playerId, sizeof(playerId));
  AssertStrEq("Steam ID Spectator", playerId, "76561197996426761");
  AssertStrEq("Spectator Team Name", g_TeamNames[Get5Team_Spec], "Spectator Team Name");

  AssertEq("Map List Length", g_MapsToPlay.Length, 3);
  char mapName[32];
  g_MapsToPlay.GetString(0, mapName, sizeof(mapName));
  AssertStrEq("Map 1 Name", mapName, "de_dust2");
  g_MapsToPlay.GetString(1, mapName, sizeof(mapName));
  AssertStrEq("Map 2 Name", mapName, "de_mirage");
  g_MapsToPlay.GetString(2, mapName, sizeof(mapName));
  AssertStrEq("Map 3 Name", mapName, "de_inferno");

  AssertEq("Map sides length", g_MapSides.Length, 3);
  AssertEq("Sides 0", view_as<int>(g_MapSides.Get(0)), view_as<int>(SideChoice_KnifeRound));
  AssertEq("Sides 1", view_as<int>(g_MapSides.Get(1)), view_as<int>(SideChoice_Team1T));
  AssertEq("Sides 2", view_as<int>(g_MapSides.Get(2)), view_as<int>(SideChoice_Team1CT)); // only 2 sides present in the file, and side_type: never_knife = team 1 ct

  AssertStrEq("Match ID", g_MatchID, "test_match_valid");
  AssertStrEq("Match Title", g_MatchTitle, "Test {MAPNUMBER} of {MAXMAPS}");
  AssertEq("Maps to win", g_MapsToWin, 2);
  AssertEq("Maps in series", g_NumberOfMapsInSeries, 3);
  AssertEq("Players per team", g_PlayersPerTeam, 5);
  AssertEq("Coaches per team", g_CoachesPerTeam, 1);
  AssertEq("Min players to ready", g_MinPlayersToReady, 3);
  AssertEq("Min spectators to ready", g_MinSpectatorsToReady, 1);
  AssertEq("Clinch series", g_SeriesCanClinch, true);
  AssertEq("Sides type", view_as<int>(g_MatchSideType), view_as<int>(MatchSideType_NeverKnife));
  AssertEq("Veto first", view_as<int>(g_LastVetoTeam), view_as<int>(Get5Team_1));
  AssertEq("Skip veto", g_SkipVeto, true);
  AssertEq("Favored percentage team 1", g_FavoredTeamPercentage, 75);
  AssertStrEq("Favored team text", g_FavoredTeamText, "team percentage text");
  AssertEq("Game state", view_as<int>(g_GameState), view_as<int>(Get5State_Warmup));

  AssertConVarEquals("mp_teamname_1", "Team A Default [NOT READY]");
  AssertConVarEquals("mp_teamflag_1", "US");
  AssertConVarEquals("mp_teamlogo_1", "logofilename");
  AssertConVarEquals("mp_teammatchstat_1", "Defending Champions");
  AssertConVarEquals("mp_teamscore_1", "");

  AssertConVarEquals("mp_teamname_2", "Team B Default [NOT READY]");
  AssertConVarEquals("mp_teamflag_2", "DE");
  AssertConVarEquals("mp_teamlogo_2", "fromfile_team");
  AssertConVarEquals("mp_teammatchstat_2", "0"); // blank match text = use map series score
  AssertConVarEquals("mp_teamscore_2", "");

  AssertConVarEquals("mp_teamprediction_txt", "team percentage text");
  AssertConVarEquals("mp_teamprediction_pct", "75");
  AssertConVarEquals("mp_teammatchstat_txt", "Test 1 of 3");

  g_RoundBackupPathCvar.SetString("addons/sourcemod/configs/get5/tests/backups/{MATCHID}/");
  g_BackupSystemEnabledCvar.BoolValue = true;
  g_ServerIdCvar.IntValue = 1234;
  WriteBackup();

  char backupFilePath[PLATFORM_MAX_PATH];
  FormatEx(backupFilePath, sizeof(backupFilePath), "addons/sourcemod/configs/get5/tests/backups/%s/%s", g_MatchID, "get5_backup1234_matchtest_match_valid_map0_prelive.cfg");
  AssertTrue("Check backup file exists", FileExists(backupFilePath));

  KeyValues backup = new KeyValues("Backup");
  AssertTrue("Read backup file", backup.ImportFromFile(backupFilePath));

  AssertEq("Backup game state", backup.GetNum("gamestate", -1), view_as<int>(Get5State_Warmup));
  AssertEq("Backup team1 side", backup.GetNum("team1_side", -1), view_as<int>(Get5Side_CT));
  AssertEq("Backup team2 side", backup.GetNum("team2_side", -1), view_as<int>(Get5Side_T));
  AssertEq("Backup team1 start side", backup.GetNum("team1_start_side", -1), view_as<int>(Get5Side_CT));
  AssertEq("Backup team2 start side", backup.GetNum("team2_start_side", -1), view_as<int>(Get5Side_T));
  AssertEq("Backup team1 score", backup.GetNum("team1_series_score", -1), 0);
  AssertEq("Backup team2 score", backup.GetNum("team2_series_score", -1), 0);
  AssertEq("Backup draws", backup.GetNum("series_draw", -1), 0);
  AssertEq("Backup team1 tac pause used", backup.GetNum("team1_tac_pauses_used", -1), 0);
  AssertEq("Backup team2 tac pause used", backup.GetNum("team2_tac_pauses_used", -1), 0);
  AssertEq("Backup team1 tech pause used", backup.GetNum("team1_tech_pauses_used", -1), 0);
  AssertEq("Backup team2 tech pause used", backup.GetNum("team2_tech_pauses_used", -1), 0);
  AssertEq("Backup team1 pause time used", backup.GetNum("team1_pause_time_used", -1), 0);
  AssertEq("Backup team2 pause time used", backup.GetNum("team2_pause_time_used", -1), 0);
  AssertEq("Backup map number", backup.GetNum("mapnumber", -1), 0);
  AssertTrue("Check maps key exists in backup", backup.JumpToKey("maps", false));

  int index = -1;
  if (backup.GotoFirstSubKey(false)) {
    do {
      index++;
      AssertTrue("Read map name from backup", backup.GetSectionName(mapName, sizeof(mapName)));
      if (index == 0) {
        AssertStrEq("Check map name 1 in backup", mapName, "de_dust2");
        AssertEq("Check map side 1 in backup", backup.GetNum(NULL_STRING), view_as<int>(SideChoice_KnifeRound));
      } else if (index == 1) {
        AssertStrEq("Check map name 2 in backup",mapName, "de_mirage");
        AssertEq("Check map side 2 in backup", backup.GetNum(NULL_STRING), view_as<int>(SideChoice_Team1T));
      } else if (index == 2) {
        AssertStrEq("Check map name 3 in backup", mapName, "de_inferno");
        AssertEq("Check map side 3 in backup", backup.GetNum(NULL_STRING), view_as<int>(SideChoice_Team1CT));
      }
    } while (backup.GotoNextKey(false));
    AssertTrue("Go back from maps key", backup.GoBack());
    AssertEq("Map list length in backup", index, 2);
  }
  backup.GoBack();

  AssertTrue("Check map scores exist in backup", backup.JumpToKey("map_scores", false));
  char keyName[16];
  char sectionName[16];

  index = -1;
  if (backup.GotoFirstSubKey(false)) {
    do {
      index++;
      AssertTrue("Read map index for score from backup", backup.GetSectionName(sectionName, sizeof(sectionName)));
      IntToString(index, keyName, sizeof(keyName));
      AssertStrEq("Check map index key in map score backup", sectionName, keyName);
      AssertTrue("Go to team1 score in map", backup.GotoFirstSubKey(false));
      backup.GetSectionName(sectionName, sizeof(sectionName));
      AssertStrEq("Check team1 key in backup scores", sectionName, "team1");
      AssertEq("Check team1 value in backup scores", backup.GetNum(NULL_STRING, -1), 0);
      AssertTrue("Go to team2 score in map", backup.GotoNextKey(false));
      backup.GetSectionName(sectionName, sizeof(sectionName));
      AssertStrEq("Check team2 key in backup scores", sectionName, "team2");
      AssertEq("Check team2 value in backup scores", backup.GetNum(NULL_STRING, -1), 0);
      AssertFalse("No more keys in backup scores", backup.GotoNextKey(false));
      backup.GoBack();
    } while (backup.GotoNextKey(false));
    AssertTrue("Go back from map_scores key", backup.GoBack());
    AssertEq("Map scores length in backup", index, 2);
  }
  backup.GoBack();

  AssertTrue("Delete test backup file", DeleteFile(backupFilePath));
  EndSeries(Get5Team_None, false, 0.0);
}

static void Utils_Test() {
  SetTestContext("Utils_Test");

  // MapsToWin
  AssertEq("MapsToWin1", MapsToWin(1), 1);
  AssertEq("MapsToWin2", MapsToWin(2), 2);
  AssertEq("MapsToWin3", MapsToWin(3), 2);
  AssertEq("MapsToWin4", MapsToWin(4), 3);
  AssertEq("MapsToWin5", MapsToWin(5), 3);
  AssertEq("MapsToWin6", MapsToWin(6), 4);
  AssertEq("MapsToWin7", MapsToWin(7), 4);
  AssertEq("MapsToWin8", MapsToWin(8), 5);

  // ConvertAuthToSteam64
  char input[64] = "STEAM_0:1:52245092";
  char expected[64] = "76561198064755913";
  char output[64] = "";
  AssertTrue("ConvertAuthToSteam64_1_return", ConvertAuthToSteam64(input, output));
  AssertStrEq("ConvertAuthToSteam64_1_value", output, expected);

  input = "76561198064755913";
  expected = "76561198064755913";
  AssertTrue("ConvertAuthToSteam64_2_return", ConvertAuthToSteam64(input, output));
  AssertStrEq("ConvertAuthToSteam64_2_value", output, expected);

  input = "_0:1:52245092";
  expected = "76561198064755913";
  AssertFalse("ConvertAuthToSteam64_3_return", ConvertAuthToSteam64(input, output, false));
  AssertStrEq("ConvertAuthToSteam64_3_value", output, expected);

  input = "[U:1:104490185]";
  expected = "76561198064755913";
  AssertTrue("ConvertAuthToSteam64_4_return", ConvertAuthToSteam64(input, output));
  AssertStrEq("ConvertAuthToSteam64_4_value", output, expected);
}

static void AssertConVarEquals(const char[] conVarName, const char[] expectedValue) {
  char convarBuffer[MAX_CVAR_LENGTH];
  GetConVarStringSafe(conVarName, convarBuffer, sizeof(convarBuffer));
  char testName[128];
  FormatEx(testName, sizeof(testName), "Test \"%s\" is \"%s\"", conVarName, expectedValue);
  AssertStrEq(testName, convarBuffer, expectedValue);
}

// TODO: Remove when compiling with SM 1.11 as it's built-in.
static void AssertStrEq(const char[] text, const char[] value, const char[] expected) {
  AssertTrue(text, StrEqual(value, expected));
}
