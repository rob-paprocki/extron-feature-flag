using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Linq;
using System.Reflection;
using Extron.Features.Contracts;

namespace Extron.Features.Factory
{
    // Add-only MEF dropin. Extron.Features.FeaturesProvider._Compose() builds an
    // AssemblyCatalog over "Extron.Features.Factory.dll" next to Extron.Features.dll
    // and satisfies its [Import(typeof(IUserFeatures))] from this [Export]. No shipped
    // file is modified. Version/namespace-agnostic: binds Contracts by name+version
    // 5.4.0.0 and discovers flag keys via reflection.
    [Export(typeof(IUserFeatures))]
    public class AllEnabledUserFeatures : IUserFeatures
    {
        private readonly Dictionary<string, bool> _all = BuildAllFlags();

        public UserFeatureClientStateEnum Status => UserFeatureClientStateEnum.Ready;
        public UserFeaturesClientInitialStatusEnum InitialOnlineStatus => UserFeaturesClientInitialStatusEnum.Online;
        public bool Online => true;
        public bool this[string flagName] => true;
        public DateTime? LastCheckIn => DateTime.Now;
        public string UserName { get; set; } = "FeatureFlagMode";
        public Dictionary<string, bool> AllFlags => _all;

        // Enumerate the shipped Contracts' FeatureFlagKeys consts (any namespace) so the
        // in-app Feature Flag manager lists every flag ON. The indexer already returns
        // true for any key regardless of this dictionary.
        private static Dictionary<string, bool> BuildAllFlags()
        {
            var dict = new Dictionary<string, bool>();
            try
            {
                Assembly asm = typeof(IUserFeatures).Assembly;
                Type[] types;
                try { types = asm.GetTypes(); }
                catch (ReflectionTypeLoadException ex) { types = ex.Types.Where(t => t != null).ToArray(); }
                foreach (var t in types)
                {
                    if (t == null || t.Name != "FeatureFlagKeys") continue;
                    foreach (var f in t.GetFields(BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy))
                    {
                        if (f.FieldType != typeof(string)) continue;
                        string v = null;
                        try
                        {
                            if (f.IsLiteral && !f.IsInitOnly) v = (string)f.GetRawConstantValue();
                            else if (f.IsInitOnly) v = (string)f.GetValue(null);
                        }
                        catch { }
                        if (!string.IsNullOrEmpty(v)) dict[v] = true;
                    }
                }
            }
            catch { }
            return dict;
        }
    }
}
