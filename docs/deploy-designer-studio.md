# Deploy in Designer Studio

After you have a `.zip` in `/Publish` (see [packaging.md](packaging.md)),
register it in your WEBCON environment.

## Register the package

1. Open **Designer Studio** (your own environment — `master` or `bps-on-demand`).
2. Go to **Plugin packages → New package**.
3. **Select your `.zip`** from `/Publish`.
4. After it loads, the **package and its plugins** appear in the list.

## Verify

5. Run **Verify plugins**.
   - **Success** → the plugin is registered and ready to use.
   - **Failure** → almost always a **version mismatch** between the SDK libraries you built
     against and your environment. Re-align the `WEBCON.BPS.2026.SDK.Libraries` NuGet version
     (and the VS extension) to your environment and Publish again. See
     [troubleshooting](troubleshooting.md).

## Use the plugin

6. In a process, add an action step **"Run an SDK action"** (or the **"Custom actions (SDK)"**
   dropdown) and select your plugin — e.g. **Hello World**.
7. Run it. The Hello World action logs an info line and returns a greeting message to the user.

## Requirements

- The environment must have a valid **SDK license** to register and run plugins.
