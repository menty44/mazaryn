-module(walletdb).
-export([insert/2, get_wallet/1, get_wallets/0, get_password/1,
         get_address/1,
         deposit/2, withdraw/2, generate_new_address/1]).

-include("../../records.hrl").

insert(Name, Password) ->
    F = fun() ->
          Names = mnesia:all_keys(wallet),
          case lists:member(Name, Names) of
            true ->
              wallet_name_existing;
            false ->
              {Pub_key, Priv_key} = crypto_utils:generate_key_pair(),
              Address = base58:binary_to_base58(Pub_key),
              mnesia:write(#wallet{name = Name,
                               password = erlpass:hash(Password),
                               address = [Address],
                               balance = 0,
                               pub_key = Pub_key,
                               priv_key = Priv_key})
          end
        end,
    {atomic, Res} = mnesia:transaction(F),
    Res.

generate_new_address(Name) ->
  Fun = fun() ->
          [Wallet] = mnesia:read({wallet, Name}),
          PubKey = Wallet#wallet.pub_key,
          NewAddress = hash:hash(PubKey),
          mnesia:write(Wallet#wallet{address = [NewAddress|Wallet#wallet.address]}),
          NewAddress
        end,
  {atomic, Res} = mnesia:transaction(Fun),
  Res.

get_address(Name) ->
  Fun = fun() ->
          [Wallet] = mnesia:read({wallet, Name}),
          Wallet#wallet.address
        end,
  {atomic, Res} = mnesia:transaction(Fun),
  Res.

get_wallet(Name) ->
    {atomic, [Wallet]} = mnesia:transaction(fun() ->
                                              mnesia:read({wallet, Name})
                                            end),
    Wallet.

get_wallets() ->
    Fun = fun() ->
        mnesia:all_keys(wallet)
    end,
    {atomic, Res} = mnesia:transaction(Fun),
    Res.

get_password(Name) ->
    F = fun() ->
        mnesia:read(wallet, Name)
        end,
    Res = mnesia:transaction(F),
    case Res of
      {atomic, [Wallet]} -> Wallet#wallet.password;
      {atomic, []} -> wallet_not_existed;
      _ -> error
    end.


deposit(Name, Amount) ->
  Fun = fun() ->
          [Wallet] = mnesia:read({wallet, Name}),
          mnesia:write(Wallet#wallet{balance = Wallet#wallet.balance + Amount})
        end,
  {atomic, Res} = mnesia:transaction(Fun),
  Res.

withdraw(Name, Amount) ->
  Fun = fun() ->
          [Wallet] = mnesia:read({wallet, Name}),
          CurrentBalance = Wallet#wallet.balance,
          case Amount =< CurrentBalance of
              true ->
                mnesia:write(Wallet#wallet{balance = CurrentBalance - Amount});
              false ->
                ?MSG_INSUFFICIENT_FUNDS
          end
        end,
  {atomic, Res} = mnesia:transaction(Fun),
  Res.