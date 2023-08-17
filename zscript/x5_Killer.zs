// SPDX-FileCopyrightText: 2019-2020, 2022-2023 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class x5_Killer : Actor
{

  Default
  {
    Height 30;
    FloatBobStrength 0.2;

    +NOBLOCKMAP;
    +NOGRAVITY;
    +DONTSPLASH;
    +NOTONAUTOMAP;
    +FLOATBOB;
    +BRIGHT;
  }

  States
  {
  Spawn:
    m8rd A - 1;
    Stop;
  }

  override void Tick()
  {
    Super.Tick();

    if (mWatched == NULL) { return; }

    setOrigin(makePosition(mWatched), true);

    if (mWatched.health > 0 && mWatched.target == NULL) { return; }

    mWatched.A_Die();
    mWatched.bCorpse = x5_raise_divided;
    destroy();
  }

  void init(Actor watched) { mWatched = watched; }
  static Vector3 makePosition(Actor watched) { return watched.pos + (0, 0, watched.height * 1.5); }

  // private: //////////////////////////////////////////////////////////////////////////////////////

  private
  Actor mWatched;

} // class x5_Killer
