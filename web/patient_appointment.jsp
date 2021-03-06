<%@page import="java.text.DateFormat"%>
<%@page import="java.sql.*"%>
<%@ page import="java.io.*,java.util.Locale" %>
<%@ page import="java.text.*,java.util.Date" %>
<% 
    /*For page tab/button/menu active state */
    session.setAttribute("pagetitle","Appoinment");
    session.setAttribute("tab","search");
    session.setAttribute("patientDetailMenu","appointment");
    
    /*Database connection */
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/clinic_receptionist", "root", "");
    Statement myStatement = con.createStatement();
    Statement doctorStatement = con.createStatement();
    Statement appointmentStatement = con.createStatement();

    /* Get current date */
    Date d = new Date(); //request for locale date
    SimpleDateFormat formatter=new SimpleDateFormat("EEEE, d MMMM yyyy");
    SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
    String date=formatter.format(d);
    String dateC=sdf.format(d); //this is for query bcus the format is different
    
    /* Get PID from previous search page */
    String PID = (String)session.getAttribute("PID");
    PID = PID.toUpperCase();
    ResultSet doctorList;
    
    /* Query linking TABLE appointment + gp + main_table */
    ResultSet result = myStatement.executeQuery("SELECT appointment.*, main_table.LastName "
            + "FROM appointment, gp, main_table WHERE appointment.Patient_ID = '" +PID+"' "
            + "AND appointment.GP_ID = gp.GP_ID and gp.User_ID = main_table.User_ID");
    
    doctorList = doctorStatement.executeQuery("SELECT main_table.LastName, gp.* FROM main_table, gp "
            + "WHERE main_table.Category = 'GP' AND main_table.User_ID = gp.User_ID");
    String GP_ID = request.getParameter("doctorSelected");
    if(request.getParameter("makeAppointment") != null) {
        appointmentStatement.execute("INSERT INTO appointment (Patient_ID, GP_ID, Date, Status) VALUES ("+PID+","+GP_ID+" )");
    }
%>
<!doctype html>
<html lang="en">
    <head>
        <jsp:include page="head.jsp"></jsp:include>

        <link rel="stylesheet" href="assets/css/bootstrap-datetimepicker.min.css">
    </head>
    <body>
        <!-- The NavBar -->
        <jsp:include page="navbar.jsp"></jsp:include>

        <div class="col-md-3">
            <jsp:include page="nav_patient_detail.jsp"></jsp:include>
        </div>
            <div class="col-md-9">
                <jsp:include page="info_patient.jsp"></jsp:include>
                <table class="table table-hover table-condensed">
                    <thead>
                        <tr>
                            <th></th>
                            <th>General practice ID</th>
                            <th>General practice name</th>
                            <th>Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%while(result.next()) {%>
                        <tr>
                            <td><a class="btn btn-warning btn-sm" href="#" role="button" data-toggle="modal" data-target="#editModal"><span class="glyphicon glyphicon-pencil"></span>&nbsp;&nbsp;Change</a>
                            <a class="btn btn-danger btn-sm" href="#" role="button" data-toggle="modal" data-target="#cancelModal"><span class="glyphicon glyphicon-minus-sign"></span>&nbsp;&nbsp;Cancel</a></td>
                            <td><%=result.getString("GP_ID")%></td>
                            <td>Dr. <%=result.getString("LastName")%></td>
                            <td><%=result.getString("Date")%></td>
                            <td><%=result.getString("Status")%></td>
                        </tr>
                        <%}%>
                    </tbody>
                </table>
                <hr>
                <button type="button" class="btn btn-success" data-toggle="modal" data-target="#addModal"><span class="glyphicon glyphicon-plus"></span>&nbsp;&nbsp;Add</button>
            </div>

            <!-- Change Appointment Date Modal -->
            <div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="editAppointment" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                            <h4 class="modal-title" id="editAppointment"><span class="glyphicon glyphicon-calendar"></span>&nbsp;&nbsp;Choose a new date</h4>
                        </div>
                        <div class="modal-body">
                            <p>Current date: <% out.println(date); %></p>
                            <br>
                            <div class="form-group">
                                <div class='input-group date' id='dateChange'>
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-calendar"></span>
                                    </span>
                                    <input type='text' class="form-control" data-date-format="DD/MM/YYYY" placeholder="Pick a date..">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal"><span class="glyphicon glyphicon-remove"></span>&nbsp;&nbsp;Close</button>
                            <button type="button" class="btn btn-success"><span class="glyphicon glyphicon-ok"></span>&nbsp;&nbsp;Update</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cancel Appointment Modal -->
            <div class="modal fade" id="cancelModal" tabindex="-1" role="dialog" aria-labelledby="cancelAppointment" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                            <h4 class="modal-title" id="cancelAppointment"><span class="glyphicon glyphicon-calendar"></span>&nbsp;&nbsp;Cancel the appointment on dd/mm/yyyy</h4>
                        </div>
                        <div class="modal-body">
                            <p>Are you sure?</p>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal"><span class="glyphicon glyphicon-remove"></span>&nbsp;&nbsp;Close</button>
                            <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus-sign"></span>&nbsp;&nbsp;Cancel appointment</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Add Appointment Date Modal -->
            <div class="modal fade" id="addModal" tabindex="-1" role="dialog" aria-labelledby="addAppointment" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                            <h4 class="modal-title" id="addAppointment"><span class="glyphicon glyphicon-calendar"></span>&nbsp;&nbsp;Choose a general practice and pick a date</h4>
                        </div>
                        <form class="form-horizontal" role="form" method="post">
                            <div class="modal-body">
                                <p>Today's date: 02/11/2014</p>

                                <!-- Datetime picker reference: http://eonasdan.github.io/bootstrap-datetimepicker/ -->
                                <p>Select a general practice (optional): </p>
                                <select class="form-control">
                                    <option>Select a general practice..</option>
                                    <%while(doctorList.next()) { %>
                                    <option name="doctorSelected" value="<%=doctorList.getString("GP_ID")%>">Doctor <%=doctorList.getString("LastName")%> - <%=doctorList.getString("GP_ID")%> </option>
                                    <% session.setAttribute("GP_ID", doctorList.getString("GP_ID")); %>
                                    <%}%>
                                </select>
                                <br>
                                <div class="form-group">
                                    <div class='input-group date' id='dateAdd'>
                                        <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                                        <input type='text' class="form-control" data-date-format="YYYY-MM-DD" placeholder="Pick a date..">
                                    </div>
                                    <p class="help-block"><span class="glyphicon glyphicon-info-sign"></span>&nbsp;Press the calendar icon to pick a date.</p>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal"><span class="glyphicon glyphicon-remove"></span>&nbsp;&nbsp;Close</button>
                                <button name='makeAppointment' type="button" class="btn btn-success"><span class="glyphicon glyphicon-ok"></span>&nbsp;&nbsp;Make appointment</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Bootstrap core JavaScript
            ================================================== -->
            <!-- Placed at the end of the document so the pages load faster -->
            <!-- Testing with new version JQuery 2.1.1 -->
            <!-- JQuery MUST put before Bootstrap JS because Bootstrap needs to read the file first -->
            <script src="assets/js/jquery-2.1.1.min.js"></script>
            <script src="assets/js/moment.min.js"></script>
            <script src="assets/js/bootstrap-datetimepicker.min.js"></script>
            <script src="assets/js/bootstrap.min.js"></script>
            <!-- JavaScript - Change appointment -->
            <script type="text/javascript">
                $(function () {
                    $('#dateChange').datetimepicker({
                            pickTime: false
                    });
                });
            </script>
            <!-- JavaScript - Add appointment -->
            <script type="text/javascript">
                $(function () {
                    $('#dateAdd').datetimepicker({
                            pickTime: false
                    });
                });
            </script>
    </body>
</html>