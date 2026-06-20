<%
  // Include di awal setiap halaman admin
  Integer _adminId = (Integer) session.getAttribute("userId");
  String  _role    = (String)  session.getAttribute("role");
  if (_adminId == null || !"admin".equals(_role)) {
    response.sendRedirect(request.getContextPath() + "/mahasiswa/login.jsp");
    return;
  }
  String _adminName = (String) session.getAttribute("userName");
%>
