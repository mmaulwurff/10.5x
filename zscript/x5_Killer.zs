// SPDX-FileCopyrightText: 2019-2020, 2022 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class x5_Killer : Inventory
{

// public: /////////////////////////////////////////////////////////////////////

  override void Tick()
  {
    Super.Tick();

    if (owner == NULL || owner.target == NULL) return;

    owner.A_Die();
    owner.bCorpse = x5_raise_divided;
    destroy();
  }

} // class x5_Killer
