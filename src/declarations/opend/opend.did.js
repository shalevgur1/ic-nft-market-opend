export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'getListedNFTs' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getListedNftPrice' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'getOpendCanisterPrinc' : IDL.Func([], [IDL.Principal], ['query']),
    'getOriginalOwner' : IDL.Func([IDL.Principal], [IDL.Principal], ['query']),
    'getOwnedNFTs' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(IDL.Principal)],
        ['query'],
      ),
    'isListed' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'listItem' : IDL.Func([IDL.Principal, IDL.Nat], [IDL.Text], []),
    'mint' : IDL.Func([IDL.Vec(IDL.Nat8), IDL.Text], [IDL.Principal], []),
    'purchase' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Principal],
        [IDL.Text],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
