use crate::common::git;
use crate::filesystem;
use crate::finder::structures::{Opts as FinderOpts, SuggestionType};
use crate::finder::FinderChoice;
use crate::prelude::*;
use std::{fs, path};

const source_file: &str = file!();

fn ask_if_should_import_all(finder: &FinderChoice) -> Result<bool> {
    let opts = FinderOpts {
        column: Some(1),
        header: Some("Do you want to import all files from this repo?".to_string()),
        ..Default::default()
    };

    let (response, _) = finder
        .call(opts, |stdin| {
            stdin
                .write_all(b"Yes\nNo")
                .context("Unable to writer alternatives")?;
            Ok(())
        })
        .context("Unable to get response")?;

    Ok(response.to_lowercase().starts_with('y'))
}

fn import_into_tmp_then_select(remote_uri: &String, destination_uri: &String, finder: FinderChoice) -> Result<()> {
    let (repo_uri, user, repo) = git::meta(remote_uri.as_str());
    let tmp_pathbuf = filesystem::tmp_pathbuf()?;
    let tmp_path_str = &tmp_pathbuf.to_string();
    let mut definitive_uri = destination_uri.clone();
    definitive_uri = definitive_uri + &format!("/{user}__{repo}");

    let _ = filesystem::remove_dir(&tmp_pathbuf);
    filesystem::create_dir(&tmp_pathbuf)?;
    filesystem::create_dir(&path::PathBuf::from(&definitive_uri))?;

    git::shallow_clone(&repo_uri, tmp_path_str)
    .with_context(|| format!("Failed to clone `{repo_uri}`"))?;

    let all_files = filesystem::all_cheat_files(&tmp_pathbuf).join("\n");

    let opts = FinderOpts {
        suggestion_type: SuggestionType::MultipleSelections,
        preview: Some(format!("cat '/{{}}'")),
        header: Some("Select the cheatsheets you want to import with <TAB> then hit <Enter>\nUse Ctrl-R for (de)selecting all".to_string()),
        preview_window: Some("right:30%".to_string()),
        ..Default::default()
    };

    let files = {
        let (files, _) = finder
            .call(opts, |stdin| {
                stdin
                    .write_all(all_files.as_bytes())
                    .context("Unable to prompt cheats to import")?;
                Ok(())
            })
            .context("Failed to get cheatsheet files from finder")?;
        files
    };

    for file in files.split('\n') {
        let from = {
            let mut p = tmp_pathbuf.clone();
            p.push(file);
            p
        };

        let filename = file
            .replace(&format!("{}{}", &tmp_path_str, path::MAIN_SEPARATOR), "")
            .replace(path::MAIN_SEPARATOR, "__");

        let to = {
            let p = definitive_uri.to_owned() + &format!("/{filename}");
            p
        };

        fs::copy(&from, &to)
            .with_context(|| format!("{} - Failed to copy `{}` to `{}`", source_file, &from.to_string(), &to.to_string()))?;
    }

    // We are copying the `.git` folder to be able to sync the repository later on
    filesystem::copy_git_dir(&tmp_path_str, &definitive_uri);
    filesystem::remove_dir(&tmp_pathbuf)?;

    Ok(())
}

fn  import_into_cheats_path(remote_uri: &String, destination_uri: &String) -> Result<()> {
    let (repo_uri, user, repo) = git::meta(remote_uri.as_str());
    let mut cheats_uri = destination_uri.clone();

    cheats_uri = cheats_uri + &format!("/{user}__{repo}");

    eprintln!("Cloning {} into {}...\n", repo_uri, cheats_uri);

    git::shallow_clone(&repo_uri, &cheats_uri)
    .with_context(|| format!("{} - Failed to clone `{remote_uri}`", source_file))
}

pub fn main(uri: String) -> Result<()> {
    let finder = CONFIG.finder();
    let cheat_pathbuf = CONFIG.path().clone().unwrap_or(filesystem::default_cheat_pathbuf()?.to_string());

    let should_import_all = ask_if_should_import_all(&finder).unwrap_or(false);

    return if should_import_all {
        import_into_cheats_path(&uri, &cheat_pathbuf)
    } else {
        import_into_tmp_then_select(&uri, &cheat_pathbuf, finder)
    };

    // Ok(())
}
