## Google Drive locations for pre-run simulation objects
## these are used when config option 'prerun' is true

gdriveURL <- "https://drive.google.com/drive/folders/1pFpAZwFqRIWxAygntEx8rVPV_b2BTqMB/"

gdriveSims <- switch(
  studyAreaName,
  AB = list(
    simOutPreamble = "1_uE5DsjvSDmcRJxoNCs5izr2uYtGSImy",
    biomassMaps2001 = "1cU2e0GFE4Ti_E5vBQy9TTXU-mzRL3xjV",
    biomassMaps2011 = "1bMkZQnW4ELiy7la1etMAGFA7O33ooE-h",
    fSsimDataPrep = "1qwEw_NvXfqpZSrILmT9ZOORRLXF6DuI3",
    ignitionOut = "",
    escapeOut = "",
    spreadOut = ""
  ),
  BC = list(
    simOutPreamble = "1edMzH3E4q1f7kdmdSRFcuEEE1MdegUWc",
    biomassMaps2001 = "12iGj3nAgr5fdKidf5ru32A6voCVC-qQx",
    biomassMaps2011 = "18xPAviLGUuN8XFINLBDmpAkKBh-C0ybV",
    fSsimDataPrep = "1fCvpQ7w6-jjyLB7kjKL6L5d1dfyOaIkJ",
    ignitionOut = "",
    escapeOut = "",
    spreadOut = ""
  ),
  MB = list(
    simOutPreamble = "1WznBdEwuo9lBK1xkOw9P84dKrcn3OasT",
    biomassMaps2001 = "1PqeJWDh1ZBVHPokqJ9Hjmr0ZBEUbNHKi",
    biomassMaps2011 = "1xC9pSM3P22106uN4XekTWlE7lpYgP5_I",
    fSsimDataPrep = "1CDV5a-0IXJA0cJWroqSmkJGJQBUTRSxS",
    ignitionOut = "",
    escapeOut = "1fYvOci3zofb4yRluiaTl6NrVFFa738Yc",
    spreadOut = "1S898TKgz1GkVsBQJX9-LQk5S2_Sr8CXA"
  ),
  NT = list(
    simOutPreamble = "1gx09K9gbBcKgV43-n3Le-u5_-8EQe4pr",
    biomassMaps2001 = "1wAoje96tK15b8Ovg6gtR16HHCb4t_49A",
    biomassMaps2011 = "1cSSbADBd-6LPBvnfbY8vefu8I4iFygsu",
    fSsimDataPrep = "1kla8pX3_QmPW3ZY_R8cdFQQah5NFc2-S",
    ignitionOut = "",
    escapeOut = "1RNuOUxff8oQVHL6Gx7AWm2UJ4LwT0Nf_",
    spreadOut = "1NJp3j-F9Y8_6hqVaEB1eExrulGtwTvEb"
  ),
  SK = list(
    simOutPreamble = "1ZjbUFqaZZLV60WVPXaO2ZnMUepiU8ju9",
    biomassMaps2001 = "1iqBhXSeCJTMV331ufWjTQk7n-jMekN0s",
    biomassMaps2011 = "1AxtVqPdoV1NJ_UUhIjnwrygGCIpTMann",
    fSsimDataPrep = "1d8LBNwbKQ9NRxr8laFctLJGbplqcwpFa",
    ignitionOut = "",
    escapeOut = "",
    spreadOut = ""
  ),
  YT = list(
    simOutPreamble = "1U1UHf7lWEiBjtc51Lftn-He56S2MIjk6",
    biomassMaps2001 = "165N8zzQa0IxZHLZMjhYZbQ85K1Ca12aW",
    biomassMaps2011 = "1gMFRn3NBEUNhMg43cJSH6GLcgQ-PYXqc",
    fSsimDataPrep = "1Gkkzet1rIUF4Ahc8aSB3dQwSeCCdSxKR",
    ignitionOut = "",
    escapeOut = "1EGlPDzu6BSlW2cj7otNnlZf4JBqzKm-J",
    spreadOut = "18CsY1Vw1s8bqEas-2fwO3CSmgQ4m7x_D"
  ),
  RIA = list(
   simOutPreamble = "",
   biomassMaps2001 = "",
   biomassMaps2011 = "",
   fSsimDataPrep = "",
   ignitionOut = "",
   escapeOut = "",
   spreadOut = ""
 )
)
