**`CompanyStructureHelper`** — `WebCon.WorkFlow.SDK.Tools.Users`

BPS organization structure operations

- `Task<BpsAccount> GetManagerAsync(String userBpsID)` *(method)* — Gets supervisor
- `Task<BpsAccount> GetManagerByElementContextAsync(String userBpsID, Int32 elementID)` *(method)* — Gets supervisor
- `Task<BpsAccount> GetManagerByProcessContextAsync(String userBpsID, Int32 processID)` *(method)* — Gets supervisor
- `Task<List<BpsAccount>> GetSubordinatesAsync(String managerBpsID)` *(method)* — Gets a list of subordinates
- `Task<List<BpsAccount>> GetSubordinatesByElementContextAsync(String managerBpsID, Int32 elementID)` *(method)* — Gets a list of subordinates
- `Task<List<BpsAccount>> GetSubordinatesByProcessContextAsync(String managerBpsID, Int32 processID)` *(method)* — Gets a list of subordinates
