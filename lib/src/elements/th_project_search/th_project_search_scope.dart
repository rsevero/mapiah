// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// The two explicit search surfaces for multi-file find/replace.
///
/// - [openTextTabs]: every open `thconfig`/`.th` text-editor tab, including
///   standalone tabs outside the loaded project (searchable/navigable but not
///   replace-eligible).
/// - [projectFiles]: every unique writable `THConfigFileNode`/`THDataFileNode`
///   in the loaded project, including unopened files.
enum THProjectSearchScope { openTextTabs, projectFiles }
