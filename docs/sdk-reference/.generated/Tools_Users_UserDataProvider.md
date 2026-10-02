**`UserDataProvider`** — `WebCon.WorkFlow.SDK.Tools.Users`

Auxiliary class: user data.

- `Task<List<BpsAccount>> GetUsersFromGroupAsync(ADGroupSearchParameters getUsersParams)` *(method)* — Getting users from Active Directory group (subgroups included)
- `Task<BpsAccount> ValidateAsync(ADGroupSearchParameters searchParams)` *(method)* — Searching Active Directory group by given phrase
- `BpsAccount CurrentUser` *(property)* — Gets data of current user BpsID, display name, email
