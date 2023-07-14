// SPDX-FileCopyrightText: 2023 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class x5_TypeMultipliersMenu : OptionMenu
{
  override bool MenuEvent(int mKey, bool fromController)
  {
    if (mKey == MKEY_Back) { report(); }

    return Super.MenuEvent(mKey, fromController);
  }

  void setEventHandler(EventHandler anEventHandler) { mEventHandler = anEventHandler; }

  // private: //////////////////////////////////////////////////////////////////////////////////////

  private
  void report()
  {
    Dictionary typeMultipliers = Dictionary.Create();
    let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("x5_TypeMultipliers"));
    foreach (menuItem : menuDescriptor.mItems)
    {
      let slider = OptionMenuItemX5TypeSlider(menuItem);
      typeMultipliers.Insert(slider.getType().GetClassName(),
                             String.Format("%d", slider.getValue()));
    }

    String event = String.Format("x5_%s", typeMultipliers.ToString());
    mEventHandler.SendNetworkEvent(event);
  }

  private
  EventHandler mEventHandler;
}
