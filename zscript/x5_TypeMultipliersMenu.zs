// SPDX-FileCopyrightText: 2023 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class x5_TypeMultipliersMenu : OptionMenu
{
  override bool MenuEvent(int mKey, bool fromController)
  {
    if (mKey == MKEY_Back) { report(); }

    return Super.MenuEvent(mKey, fromController);
  }

  void setUp(EventHandler anEventHandler, Dictionary enemyTypes)
  {
    mEventHandler = anEventHandler;

    mDesc.mItems.clear();
    mDesc.mSelectedItem = 2;

    String description = StringTable.Localize("$X_EXIT");
    mDesc.mItems.push(new ("OptionMenuItemStaticText").InitDirect(description, Font.CR_BLACK));
    mDesc.mItems.push(new ("OptionMenuItemStaticText").Init(""));

    let savedMultipliers = Dictionary.FromString(x5_type_multipliers);
    for (let i = DictionaryIterator.Create(savedMultipliers); i.Next();)
    {
      String type = i.Key();

      if (enemyTypes.at(type).Length() != 0)
      {
        int multiplier = i.Value().ToInt();
        enemyTypes.Insert(type, String.Format("%d", multiplier));
      }
    }

    Array<x5_TypeSortElement> types;

    for (let i = DictionaryIterator.Create(enemyTypes); i.Next();)
    {
      Class<Actor> enemyClass = i.Key();
      int multiplier          = i.Value().ToInt();
      let defaultEnemy        = getDefaultByType(enemyClass);

      let element         = new ("x5_TypeSortElement");
      element.mName       = defaultEnemy.getTag();
      element.mHealth     = defaultEnemy.health;
      element.mClass      = enemyClass;
      element.mMultiplier = multiplier;
      types.push(element);
    }

    sortTypes(types);

    foreach (element : types)
    {
      let slider = new ("OptionMenuItemX5TypeSlider");
      slider.Init(element.mClass, element.mMultiplier);

      mDesc.mItems.push(slider);
    }
  }

  // private: //////////////////////////////////////////////////////////////////////////////////////

  private
  void report()
  {
    let savedMultipliers = Dictionary.FromString(x5_type_multipliers);
    Dictionary multipliersToReport = Dictionary.Create();
    foreach (menuItem : mDesc.mItems)
    {
      let slider = OptionMenuItemX5TypeSlider(menuItem);
      if (slider == NULL) continue;

      STring className  = slider.getType().GetClassName();
      String multiplier = String.Format("%d", slider.getValue());
      multipliersToReport.Insert(className, multiplier);
      savedMultipliers.Insert(className, multiplier);
    }

    CVar.FindCVar("x5_type_multipliers").SetString(savedMultipliers.ToString());

    String event = String.Format("x5_%s", multipliersToReport.ToString());
    mEventHandler.SendNetworkEvent(event);
  }

  private
  void sortTypes(out Array<x5_TypeSortElement> types)
  {
    // Gnome sort (stupid sort): https://en.wikipedia.org/wiki/Gnome_sort

    let pos    = 0;
    let length = types.size();

    while (pos < length)
    {
      if (pos == 0 || isGreaterOrEqual(types[pos], types[pos - 1])) { ++pos; }
      else
      {
        // swap
        let tmp        = types[pos];
        types[pos]     = types[pos - 1];
        types[pos - 1] = tmp;

        --pos;
      }
    }
  }

  private

  private
  bool isGreaterOrEqual(x5_TypeSortElement element1, x5_TypeSortElement element2)
  {
    if (element1.mHealth > element2.mHealth) { return true; }
    if (element1.mHealth == element2.mHealth && element1.mName >= element2.mName) { return true; }

    return false;
  }

  private
  EventHandler mEventHandler;

} // class x5_TypeMultipliersMenu

class x5_TypeSortElement
{

  String mName;
  int mHealth;
  Class<Actor> mClass;
  int mMultiplier;

} // class x5_TypeSortElement
