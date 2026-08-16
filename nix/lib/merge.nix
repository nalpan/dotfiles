# JSON設定の合成に使う汎用関数
rec {
  # リストの重複を除去する(順序は保持)
  uniqueList = xs:
    builtins.foldl' (acc: x: if builtins.elem x acc then acc else acc ++ [ x ]) [ ] xs;

  # 属性セットは再帰的にマージ、リストは連結して重複除去、それ以外は b(端末固有)が優先
  deepMerge = a: b:
    let
      mergeKey = k:
        if !(a ? ${k}) then b.${k}
        else if !(b ? ${k}) then a.${k}
        else if builtins.isAttrs a.${k} && builtins.isAttrs b.${k} then deepMerge a.${k} b.${k}
        else if builtins.isList a.${k} && builtins.isList b.${k} then uniqueList (a.${k} ++ b.${k})
        else b.${k};
    in
    builtins.listToAttrs (map (k: { name = k; value = mergeKey k; }) (builtins.attrNames (a // b)));
}
