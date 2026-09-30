/// What goes on the exported campus pass image: the join code encoded in
/// the QR, plus the university name printed under it.
class CampusPass {
  const CampusPass({required this.campusId, this.universityName});

  final String campusId;
  final String? universityName;
}

/// Where the OS share sheet should pop over from, in global logical
/// pixels — required on iPad and macOS, ignored on phones.
typedef ShareAnchor = ({double left, double top, double width, double height});
